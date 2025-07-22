const {setGlobalOptions} = require("firebase-functions/v2/options");
const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {logger} = require("firebase-functions");
const admin = require("firebase-admin");

setGlobalOptions({
  maxInstances: 10,
  region: "asia-northeast3",
});

if (!admin.apps.length) {
  admin.initializeApp();
}

// Cloud Function: sendLocationRequest (상대방에게 푸시 알람 전송)
exports.sendLocationRequest = onCall({
  enforceAppCheck: false, // App Check를 사용하지 않을 경우
  region: "asia-northeast3",
}, async (request) => {
  const {targetEmail, senderName, number} = request.data;
  const context = request;

  // 인증 확인
  if (!context.auth) {
    throw new HttpsError(
        "unauthenticated",
        "The function must be called while authenticated.",
    );
  }

  try {
    // 1. 이메일로 사용자 찾기
    const userQuery = await admin.firestore()
        .collection("users")
        .where("email", "==", targetEmail)
        .limit(1)
        .get();

    if (userQuery.empty) {
      throw new HttpsError("not-found", "해당 이메일을 가진 사용자를 찾을 수 없습니다.");
    }

    const targetUserDoc = userQuery.docs[0];
    const targetUserData = targetUserDoc.data();
    const targetFCMToken = targetUserData.fcmToken;

    if (!targetFCMToken) {
      throw new HttpsError(
          "failed-precondition",
          "상대방의 FCM 토큰이 등록되어 있지 않습니다.",
      );
    }

    // 2. 푸시 알림 전송
    const message = {
      token: targetFCMToken,
      notification: {
        title: `${senderName}님의 위치 공유 요청`,
        body: `위급 상황 시 위치를 공유해도 괜찮으신가요? [동의/거절]\n연락처: ${number || "없음"}`,
      },
      data: {
        type: "location_request",
        fromUid: context.auth.uid,
        fromName: senderName,
        phoneNumber: number || "",
        targetEmail: targetEmail,
        timestamp: new Date().toISOString(),
      },
    };

    await admin.messaging().send(message);
    logger.info(`Location request sent from ${context.auth.uid} to ${targetEmail}`);

    return {success: true};
  } catch (error) {
    console.error("알림 전송 실패:", error);
    throw new Error(error.message);
  }
});
