const {onSchedule} = require("firebase-functions/v2/scheduler");
const {logger} = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");

if (!admin.apps.length) {
  admin.initializeApp();
}
const db = admin.firestore();

exports.pollDisasterMessages = onSchedule(
    {
      schedule: "every 5 minutes",
      region: "asia-northeast3",
      timeZone: "Asia/Seoul",
    },
    async (event) => {
      const baseUrl = "https://www.safetydata.go.kr/V2/api/DSSP-IF-00247";
      const serviceKey = "8FO6D9WJKB34ON28";
      const now = new Date();
      const timeString = now.toISOString().slice(0, 13).replace(/[-T]/g, ""); // 예: 2025072114
      console.log("현재 시간:", timeString);

      try {
        const response = await axios.get(baseUrl, {
          params: {
            serviceKey,
            pageNo: 1,
            numOfRows: 50,
            type: "json",
          },
        });

        const items = response.data?.DisasterMsg?.[1]?.row || [];
        if (!Array.isArray(items) || items.length === 0) {
          logger.info("No disaster messages found.");
          return null;
        }

        const alertsByRegion = {};

        for (const item of items) {
          const {create_date, location_name, md101_sn, msg} = item;
          if (!location_name || !msg) continue;

          const region = location_name.split(" ")[0];

          if (
            !alertsByRegion[region] ||
          new Date(alertsByRegion[region].createDate) < new Date(create_date)
          ) {
            alertsByRegion[region] = {
              md101_sn,
              msg,
              region,
              createDate: create_date,
            };
          }
        }

        for (const [region, alert] of Object.entries(alertsByRegion)) {
          const alertDoc = db.collection("disasterAlerts").doc(alert.md101_sn);
          const existing = await alertDoc.get();

          if (existing.exists && existing.data()?.notifiedRegions?.includes(region)) {
            logger.info(`[SKIP] Already notified for region: ${region}`);
            continue;
          }

          const usersSnapshot = await db
              .collection("users")
              .where("regions", "array-contains", region)
              .get();

          const tokens = usersSnapshot.docs
              .map((doc) => doc.data().fcmToken)
              .filter(Boolean);

          if (tokens.length === 0) {
            logger.info(`[INFO] No users subscribed to ${region}`);
            continue;
          }

          await admin.messaging().sendMulticast({
            tokens,
            notification: {
              title: `[재난알림] ${region}`,
              body: alert.msg.length > 100 ? alert.msg.slice(0, 100) + "..." : alert.msg,
            },
            data: {
              alertId: alert.md101_sn,
              region,
              type: "disaster_alert",
            },
          });

          logger.info(`[PUSH] Sent to ${tokens.length} users in ${region}`);

          await alertDoc.set(
              {
                ...alert,
                notifiedRegions: admin.firestore.FieldValue.arrayUnion(region),
                shownInUI: true, // 알림 목록에 표시할지 여부
              },
              {merge: true},
          );
        }

        return null;
      } catch (error) {
        logger.error("Error fetching disaster messages:", error);
        return null;
      }
    },
);

exports.sendLocationRequest = require("./push_index").sendLocationRequest;
