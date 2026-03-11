// api/_utils/firebase.js
const admin = require('firebase-admin');

let firebaseEnabled = false;

if (
  process.env.FIREBASE_PROJECT_ID &&
  process.env.FIREBASE_CLIENT_EMAIL &&
  process.env.FIREBASE_PRIVATE_KEY
) {
  try {
    if (!admin.apps.length) {
      admin.initializeApp({
        credential: admin.credential.cert({
          projectId: process.env.FIREBASE_PROJECT_ID,
          clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
          privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
        }),
      });

      firebaseEnabled = true;
      console.log("Firebase initialized");
    }
  } catch (error) {
    console.log("Firebase initialization failed, continuing without Firebase");
  }
} else {
  console.log("Firebase disabled for local development");
}

async function getUserEmailFromToken(token) {
  if (!firebaseEnabled || !token) {
    return null;
  }

  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    return decodedToken.email;
  } catch (error) {
    console.error("Error verifying Firebase token:", error);
    return null;
  }
}

module.exports = {
  admin,
  getUserEmailFromToken
};