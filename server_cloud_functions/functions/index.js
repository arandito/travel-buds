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
  if (req.auth != true) {
    throw new Error("You must be authenticated to call this function.");
  }

  const mydest = req.body.destination;
  const mytimeblock = req.body.timeblock;
  const myinterest = req.body.interest;
  // Insert logic so no overlapping also time logic
  const matches = await getFirestore()
      .collection("pending")
      .doc(mytimeblock)
      .collection("destinations")
      .doc(mydest)
      .where(myinterest, "==", "interest")
      .orderBy("req_timestamp")
      .limit(4)
      .get();

  if (matches.empty) {
    logger.log("No eligible matches.");
    return "";
  }

  const mymembers = [];
  matches.forEach((doc) => {
    mymembers.push(doc);
  });

  const group = await getFirestore().collection("groups").add({
    timeblock: mytimeblock,
    destination: mydest,
    interest: myinterest,
    members: mymembers,
  });

  return group;
});
