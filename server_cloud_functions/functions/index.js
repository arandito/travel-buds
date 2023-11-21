// The Cloud Functions for Firebase SDK to create Cloud Functions and triggers.
const {logger} = require("firebase-functions/logger");
const {setGlobalOptions} = require("firebase-functions/v2/options");
const {onRequest} = require("firebase-functions/v2/https");
// const {onDocumentWritten} = require("firebase-functions/v2/firestore");

// The Firebase Admin SDK to access Firestore.
const {initializeApp} = require("firebase-admin/app");
// const {getFirestore} = require("firebase-admin/firestore");

initializeApp();
setGlobalOptions({maxInstances: 10, region: "us-east1"});

exports.helloWorld = onRequest((request, response) => {
  logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});
