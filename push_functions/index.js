const {setGlobalOptions} = require("firebase-functions");


setGlobalOptions({maxInstances: 10});



// 여기부터 7월 22일 새벽 1시 6시에  상대방에게 push 알람이 가게 하기 위해 추가한 함수
// Cloud Function: sendLocationRequest (상대방에게 푸시 알람 전송)
const functions=require("firebase-functions");
const admin=require("firebase-admin");


if (!admin.apps.length) {
  admin.initializeApp();
}

// cloud functions인 sendLoationRequest 구현 중
// Firestore에서 상대방 이메일로 fcmToken을 찾아서, FCM 을 이용해 위치 공유 요청 푸시 알림을 보내는 기능
exports.sendLocationRequest=functions.https.onCall(async (data, context)=>{
  const targetEmail=data.targetEmail;
  const senderName=data.senderName;

  if (!context.auth) {
    throw new functions.https.HttpsError(
        "unauthenticated",
        "The function must be called while authenticated.",
    );
  }

  try {
    // 1.이메일로 사용자 찾기
    const userQuery=await admin.firestore().collection("users")
        .where("email", "==", targetEmail)
        .limit(1)
        .get();

    if (userQuery.empty) {
      throw new functions.https.HttpsError(
          "not-found",
          "해당 이메일을 가진 사용자를 찾을 수 없습니다.",
      );
    }

    const targetUserDoc=userQuery.docs[0];
    const targetFCMToken=targetUserDoc.data().fcmToken;

    if (!targetFCMToken) {
      throw new functions.https.HttpsError(
          "failed-precondition",
          "상대방의 FCM 토큰이 등록되어 있지 않습니다.",
      );
    }

    // 2.푸시 알림 전송
    const message={
      token: targetFCMToken,
      notification: {
        title: `${senderName}님의 위치 공유 요청`,
        body: "위급 상황 시 위치를 공유해도 괜찮으신가요? [동의/거절]",
      },
      data: {
        type: "location_request",
        fromUid: context.auth.uid,
      },
    };
    await admin.messaging().send(message);

    return {success: true};
  } catch (error) {
    console.error("알림 전송 실패:", error);
    throw new functions.https.HttpsError("internal", error.message);
  }
});
