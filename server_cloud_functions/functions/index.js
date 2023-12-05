// The Cloud Functions for Firebase SDK to create Cloud Functions and triggers.
const {logger} = require("firebase-functions");
const {setGlobalOptions} = require("firebase-functions/v2/options");
const {onRequest} = require("firebase-functions/v2/https");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");

// The Firebase Admin SDK to access Firestore. Also for document field
// array operations and batch writes.
const {initializeApp} = require("firebase-admin/app");
const {getFirestore, FieldValue, Timestamp, FieldPath} =
    require("firebase-admin/firestore");

// Request body-parser.
const jsonParser = require("body-parser").json();

// To set up scheduled Cloud Functions.
// const {onSchedule} = require{"firebase-functions/v2/scheduler"};

initializeApp();
setGlobalOptions({maxInstances: 10, region: "us-east1", timeoutSeconds: 3});
const db = getFirestore();

exports.helloWorld = onRequest({cors: true}, (req, res) => {
  logger.info("Hello logs!", {structuredData: true});
  return res.send("Hello from Firebase!");
});

// Add functionality where user can not make multiple
// of same trip. This is easy if they are in a group for trip already.
// Might need to track pending as well?
exports.makeGroup =
onRequest({cors: true}, async (req, res) => {
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

  const myUserSnapshot = await db.collection("users").doc(myuid).get();
  const fields = myUserSnapshot.data();
  const pendingRequests = fields.pendingRequests;
  const groups = fields.groups;

  if (pendingRequests.length != 0) {
    const pendingRequestsSnapshot = await db
        .collection("pending")
        .where(FieldPath.documentId(), "in", pendingRequests)
        .get();

    pendingRequestsSnapshot.forEach((pendingDoc) => {
      const pendingData = pendingDoc.data();
      if (pendingData.weekStartDate == myWeekStartDate &&
      pendingData.destination == myDest) {
        return res.status(400).send("Cannot create group that conflicts " +
        "with pending trip dest and date.");
      }
    });
  }
  if (groups.length != 0) {
    const groupsSnapshot = await db
        .collection("groups")
        .where(FieldPath.documentId(), "in", groups)
        .get();

    groupsSnapshot.forEach((groupDoc) => {
      const groupData = groupDoc.data();
      if (groupData.weekStartDate == myWeekStartDate &&
      groupData.destination == myDest) {
        return res.status(400).send("Cannot create group that conflicts " +
        "with existing group dest and date.");
      }
    });
  }

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

// Update/Create userDocs in recentMessages with new group Doc
// with init message from travelBuddies
// Add 1 something to messages.
exports.sendInitialGroupMessage =
onDocumentCreated("groups/{groupId}", async (event) => {
  const snapshot = event.data;
  if (!snapshot) {
    console.error("No data/snapshot associated with created group.");
    return;
  }

  const groupId = snapshot.id;
  const fields = snapshot.data();
  const members = fields.members;
  const destination = fields.destination;
  const interest = fields.interest;
  const weekStartDate = fields.weekStartDate;
  const weekEndDate = fields.weekEndDate;
  const text = "Hi everyone! Say hello to your new Travel Buddies! " +
      "Note, while we've matched you " +
      "with people that would be in " + destination + " somewhere " +
      "between " + weekStartDate + " and " + weekEndDate + ", you may be " +
      "arriving and/or departing at slightly different times! This group " +
      "chat will NOT EXPIRE over time. However, you may manually leave " +
      "the group chat at any time. The Travel Buddies team hopes you " +
      "have fun in " + destination + " with " + interest + "!" +
      "\n- The Travel Buddies Team";

  const batch = db.batch();
  const timestamp = Timestamp.now();
  members.forEach((memberId) => {
    const groupRecentMessageDoc = db
        .collection("recentMessages")
        .doc(memberId)
        .collection("messages")
        .doc(groupId);

    batch.set(groupRecentMessageDoc, {
      groupId: groupId,
      senderId: "travelBuddies",
      text: text,
      timestamp: timestamp,
    });
  });

  const messageDoc = db
      .collection("messages")
      .doc(groupId)
      .collection(groupId)
      .doc();
  batch.set(messageDoc, {
    senderId: "travelBuddies",
    text: text,
    timestamp: timestamp,
  });

  try {
    await batch.commit();
  } catch (error) {
    logger.log("Error, no changes to Firestore were made.");
  }
  return;
});
