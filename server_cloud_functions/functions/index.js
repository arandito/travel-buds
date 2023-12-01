// The Cloud Functions for Firebase SDK to create Cloud Functions and triggers.
const {logger} = require("firebase-functions/logger");
const {setGlobalOptions} = require("firebase-functions/v2/options");
const {onRequest} = require("firebase-functions/v2/https");
// const {onDocumentWritten} = require("firebase-functions/v2/firestore");

// The Firebase Admin SDK to access Firestore.
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");

// To set up scheduled Cloud Functions.
//const {onSchedule} = require{"firebase-functions/v2/scheduler"};

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
  const pendingSnapshot = await getFirestore()
      .collection("pending")
      //.where(myinterest, "==", "interest")
      .orderBy("startDate")
      //.limit(5)
      .get();

  const currGroup = [];
  const fullyExplored = new Set();
  matchesSnapshot.forEach((currTripDoc) => {
    if (fullyExplored.has(currTripDoc)) {
      return;
    }
    currGroup.push(currTripDoc)
    fullyExplored.add(currTripDoc);
    groupDest = currTripDoc.get("destination");
    groupStart = currTripDoc.get("startDate");
    
    matchesSnapshot.forEach((otherTripDoc) => {
      if (!fullyExplored.has(otherTripDoc)) {

      }
    });
  });

  const group = await getFirestore().collection("groups").add({
    timeblock: mytimeblock,
    destination: mydest,
    interest: myinterest,
    members: mymembers,
  });

  return group;
});
