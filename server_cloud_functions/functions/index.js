// The Cloud Functions for Firebase SDK to create Cloud Functions and triggers.
const {logger} = require("firebase-functions");
const {setGlobalOptions} = require("firebase-functions/v2/options");
const {onRequest} = require("firebase-functions/v2/https");
// const {onDocumentWritten} = require("firebase-functions/v2/firestore");

// The Firebase Admin SDK to access Firestore. Also for document field
// array operations and batch writes.
const {initializeApp} = require("firebase-admin/app");
const {getFirestore, FieldValue} = require("firebase-admin/firestore");

// Request body-parser.
const jsonParser = require("body-parser").json();

// To set up scheduled Cloud Functions.
// const {onSchedule} = require{"firebase-functions/v2/scheduler"};

initializeApp();
setGlobalOptions({maxInstances: 10, region: "us-east1"});
const db = getFirestore();

exports.helloWorld = onRequest({timeoutSeconds: 1, cors: true}, (req, res) => {
  logger.info("Hello logs!", {structuredData: true});
  return res.send("Hello from Firebase!");
});

// Add functionality where user can not make multiple
// of same trip. This is easy if they are in a group for trip already.
// Might need to track pending as well?
exports.makeGroup =
onRequest({timeoutSeconds: 5, cors: true}, async (req, res) => {
  // if (req.auth != true) {
  //   res.status(401).send("Unauthorized:" +
  //       "Client failed to authenticate with the server.");
  //   return ""
  // }

  jsonParser(req, res, (err) => {
    if (err) {
      return res.status(400).send(err.message);
    }
  });

  // Catches error if incorrectly formatted request.
  let myuid;
  let myWeekStartDate;
  let myWeekEndDate;
  let myDest;
  let myInterest;

  try {
    myuid = req.body.uid;
    myWeekStartDate = req.body.weekStartDate;
    myWeekEndDate = req.body.weekEndDate;
    myDest = req.body.destination;
    myInterest = req.body.interest;
  } catch (error) {
    return res.status(400).send(error);
  }
  // Insert body type check

  const batch = db.batch();

  // Insert no conflicting + duplicate trips from same user check.
  const pendingsSnapshot = await db
      .collection("pending")
      .where("weekStartDate", "==", myWeekStartDate)
      .where("destination", "==", myDest)
      .where("interest", "==", myInterest)
      .limit(4)
      .get();

  // If not enough matches to form a group, add pending info to
  // appropriate tables in datastore.
  if (pendingsSnapshot.size != 4) {
    // To pending collection.
    const myPendingDoc = db.collection("pending").doc();

    batch.set(myPendingDoc, {
      weekStartDate: myWeekStartDate,
      weekEndDate: myWeekEndDate,
      destination: myDest,
      interest: myInterest,
      uid: myuid,
    });

    // To myUser's pending_requests field array.
    const myUserDoc = db.collection("users").doc(myuid);
    batch.update(myUserDoc, {
      pendingRequests: FieldValue.arrayUnion(myPendingDoc.id),
    });

    try {
      await batch.commit();
    } catch (error) {
      logger.error("Error, no changes to Firestore were made.");
      return res.status(500).send(error);
    }

    return res.status(201).json({
      group_id: "",
      pending_id: `${myPendingDoc.id}`,
    });
  }

  // Delete pending requests wherever it exists in datastore.
  // Add myGroup to each users groups array.
  // Build members array.
  const myMemberIds = [];
  const myGroupDoc = db.collection("groups").doc();

  // Handle myUser.
  myMemberIds.push(myuid);
  const myUserDoc = db.collection("users").doc(myuid);
  batch.update(myUserDoc, {
    groups: FieldValue.arrayUnion(myGroupDoc.id),
  });

  // Handle rest of users.
  pendingsSnapshot.forEach((pendingDoc) => {
    const uid = pendingDoc.get("uid");

    myMemberIds.push(uid);
    batch.delete(pendingDoc.ref);

    const userDoc = db.collection("users").doc(uid);
    batch.update(userDoc, {
      pendingRequests: FieldValue.arrayRemove(pendingDoc.id),
      groups: FieldValue.arrayUnion(myGroupDoc.id),
    });

    logger.log(`Attempting to delete pending request: ${pendingDoc.id}`);
  });

  batch.set(myGroupDoc, {
    weekStartDate: myWeekStartDate,
    weekEndDate: myWeekEndDate,
    destination: myDest,
    interest: myInterest,
    members: myMemberIds,
  });

  try {
    await batch.commit();
  } catch (error) {
    logger.log("Error, no changes to Firestore were made.");
    return res.status(500).send(error);
  }

  return res.status(201).json({
    group_id: `${myGroupDoc.id}`,
    pending_id: "",
  });
});
