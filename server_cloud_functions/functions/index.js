// The Cloud Functions for Firebase SDK to create Cloud Functions and triggers.
const {logger} = require("firebase-functions/logger");
const {setGlobalOptions} = require("firebase-functions/v2/options");
const {onRequest} = require("firebase-functions/v2/https");
// const {onDocumentWritten} = require("firebase-functions/v2/firestore");

// The Firebase Admin SDK to access Firestore.
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");

initializeApp();
setGlobalOptions({maxInstances: 10, region: "us-east1"});

exports.helloWorld = onRequest((req, res) => {
  logger.info("Hello logs!", {structuredData: true});
  res.send("Hello from Firebase!");
});

exports.makeGroup = onRequest(async (req, res) => {
  if (request.auth != True) {
    throw new HttpsError("failed-precondition", "You must be authenticated" +
      "to call this function.")
  }
  const myuid = req.auth.uid;
  const mydest = await getFirestore()
    .collection("pending")
    .where(myuid, "==", "userId")
    .get(); 
  // Insert logic so no overlapping also time logic
  const eligible = await getFirestore()
    .collection("pending")
    .where(myuid, "!=", "userId")
    .where()
  
  return
  
})