// The Cloud Functions for Firebase SDK to create Cloud Functions and triggers.
const {logger} = require("firebase-functions");
const {setGlobalOptions} = require("firebase-functions/v2/options");
const {onRequest} = require("firebase-functions/v2/https");
// const {onDocumentWritten} = require("firebase-functions/v2/firestore");

// The Firebase Admin SDK to access Firestore.
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");

// Request body-parser.
const jsonParser = require("body-parser").json();

// To set up scheduled Cloud Functions.
// const {onSchedule} = require{"firebase-functions/v2/scheduler"};

initializeApp();
setGlobalOptions({maxInstances: 10, region: "us-east1"});

exports.helloWorld = onRequest({timeoutSeconds: 1, cors: true}, (req, res) => {
  logger.info("Hello logs!", {structuredData: true});
  return res.send("Hello from Firebase!");
});

// Add functionality where user can not make multiple
// of same trip. This is easy if they are in a group for trip already.
// Might need to track pending as well?
exports.makeGroup =
onRequest({timeoutSeconds: 3, cors: true}, async (req, res) => {
  // if (req.auth != true) {
  //   res.status(401).send("Unauthorized:" +
  //       "Client failed to authenticate with the server.");
  //   return ""
  // }

  jsonParser(req, res, (err) => {
    if (err) {
      return res.status(500).send(err.message);
    }
  });

  // Catches error if incorrectly formatted request.
  let myUserId;
  let myWeekStartDate;
  let myWeekEndDate;
  let myDest;
  let myInterest;

  try {
    myUserId = req.body.uid;
    myWeekStartDate = req.body.weekStartDate;
    myWeekEndDate = req.body.weekEndDate;
    myDest = req.body.destination;
    myInterest = req.body.interest;
  } catch (error) {
    return res.status(400).send(error);
  }
  // Insert body type check
  const tripsSnapshot = await getFirestore()
      .collection("pending")
      .where(myWeekStartDate, "==", "weekStartDate")
      .where("destination", "==", myDest)
      .where("interest", "==", myInterest)
      .limit(4)
      .get();

  if (tripsSnapshot.size != 4) {
    const myTripDoc = await getFirestore().collection("pending").add({
      weekStartDate: myWeekStartDate,
      weekEndDate: myWeekEndDate,
      destination: myDest,
      interest: myInterest,
      userId: myUserId,
    });
    return res.status(201).send(`Created pending trip: ${myTripDoc.id}`);
  }

  const myMembers = [];

  myMembers.push(myUserId);
  tripsSnapshot.forEach((tripDoc) => {
    myMembers.push(tripDoc.get("userId"));
    tripDoc.ref.delete();
    logger.log(`Deleted pending trip: ${tripDoc.id}`);
  });

  const myGroupDoc = await getFirestore().collection("groups").add({
    weekStartDate: myWeekStartDate,
    weekEndDate: myWeekEndDate,
    destination: myDest,
    interest: myInterest,
    members: myMembers,
  });

  return res.status(201).send(`Group created with id: ${myGroupDoc.id}`);
});
