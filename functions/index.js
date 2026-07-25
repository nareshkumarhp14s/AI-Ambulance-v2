const {setGlobalOptions} = require("firebase-functions");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

setGlobalOptions({maxInstances: 10});

admin.initializeApp();

exports.sendPushNotification = onDocumentCreated(
    "notifications/{notificationId}",
    async (event) => {
      const snapshot = event.data;

      if (!snapshot) {
        console.log("No notification data found.");
        return;
      }

      const data = snapshot.data();

      if (!data) {
        console.log("Notification document is empty.");
        return;
      }

      const userId = data.userId;

      if (!userId) {
        console.log("userId is missing.");
        return;
      }

      try {
        const userDoc = await admin
            .firestore()
            .collection("users")
            .doc(userId)
            .get();

        if (!userDoc.exists) {
          console.log("User document not found.");
          return;
        }

        const token = userDoc.get("fcmToken");

        if (!token) {
          console.log("FCM token not found.");
          return;
        }

        const message = {
          token: token,
          notification: {
            title: data.title || "Notification",
            body: data.body || "",
          },
          data: {
            bookingId: data.bookingId ? String(data.bookingId) : "",
            type: data.type ? String(data.type) : "",
          },
          android: {
            priority: "high",
            notification: {
              sound: "default",
            },
          },
        };

        const response = await admin.messaging().send(message);

        console.log("Notification sent:", response);
      } catch (error) {
        console.error("Error sending notification:", error);
      }
    },
);
