// Importing Essentials
// const { application } = require("express");
let expressWs = require("express-ws")(require("express"));
const app = expressWs.app;
const router = app.Router();

// File System
const fs = require("fs");

// Path
const path = require("path");

// PDF pArser
const pdfParse = require("pdf-parse");

// Import pdf creator
const pdf = require("pdf-creator-node");

// Import error handler
const handleError = require("../../helpers/errorHandler");

// Import application model
const Application = require("../../models/Application");

// Import announcement model
const Announcement = require("../../models/Announcement");

// Route to get Application highlights
router.get("/applications", async (req, res) => {
  try {
    // Empty array to hold application detail
    var allApplicationsHighlight = [];

    // Get all applications from DB
    const allApplication = await Application.find();

    // Get highlights only from complete application
    allApplication.forEach((application) => {
      allApplicationsHighlight.push({
        name: application["fullName"],
        applicationId: application["_id"],
        admissionStatus: application["admissionStatus"],
      });
    });

    console.log(allApplicationsHighlight);
    res.status(200).send(allApplicationsHighlight);
  } catch (e) {
    handleError(e);
    res.status(500).send("Error");
  }
});

// Route to get application details with ID - URL PARAM
router.get("/application.:applicationId", async (req, res) => {
  try {
    const id = req.params.applicationId;

    const selectedApplication = await Application.findById(id);

    res.status(200).send(selectedApplication);
  } catch (e) {
    handleError(e);
    res.status(500).send("Error");
  }
});

router.get("/application/download/:applicationId", async (req, res) => {
  console.log("Preparing FILE");

  const html = fs.readFileSync(
    path.resolve(__dirname, "../", "../", "templates/template.html"),
    "utf8"
  );
  const id = req.params.applicationId;

  const selectedApplication = await Application.findById(id);

  if (selectedApplication != null) {
    let options = {
      format: "A4",
      orientation: "portrait",
      border: "10mm",
    };

    let applicant = [
      {
        fullName: selectedApplication.fullName,
        birthDate: selectedApplication.birthDate,
        gender: selectedApplication.gender,
        location: selectedApplication.location,
        phoneNumber: selectedApplication.phoneNumber,
        schoolTranscript: await getContent(
          selectedApplication.schoolTranscript
        ),
        mainEssay: await getContent(selectedApplication.mainEssay),
        extraEssay: selectedApplication.extraEssay,
        proficiencyTest: selectedApplication.proficencyTest,
        extraCertification: await getContent(
          selectedApplication.extraCertification
        ),
        recommendationLetter: await getContent(
          selectedApplication.recommendationLetter
        ),
        departmentSelection: selectedApplication.departmentSelection,
        militaryFamilyStatus: selectedApplication.militaryFamilyStatus,
        universityFamilyStatus: selectedApplication.universityFamilyStatus,
        date: selectedApplication.date,
      },
    ];

    let document = {
      html: html,
      data: {
        applicant: applicant,
      },
      path: `./output/${selectedApplication["fullName"]}.pdf`,
    };

    await pdf
      .create(document, options)
      .then((res) => {
        console.log(res);
      })
      .catch((e) => {
        console.error(e);
      });

    console.log("SENDING FILE");
    res.sendFile(
      path.resolve(
        __dirname,
        "../",
        "../",
        `output/${selectedApplication["fullName"]}.pdf`
      )
    );
  } else {
    res.sendStatus(404);
  }
});

// Route to update application status
router.put("/admissionStatus/:applicationId", async (req, res) => {
  try {
    const id = req.params.applicationId;

    const updatedAdmissionStatus = req.body.admissionStatus;

    const selectedApplication = Application.findById(id);

    const result = await selectedApplication.updateOne({
      admissionStatus: updatedAdmissionStatus,
    });
    console.log("HERE");
    res.status(204).send("Completed");
  } catch (e) {
    handleError(e);
    res.status(500).send("Error");
  }
});

async function getContent(fileName) {
  let dataBuffer = fs.readFileSync(
    path.resolve(__dirname, "../", "../", `uploads/${fileName}.pdf`)
  );
  await pdfParse(dataBuffer)
    .then(function (data) {
      fs.writeFileSync("./test.txt", data.text, () => {
        console.log("done");
      }),
        (content = data.text);
    })
    .catch((e) => {});

  var content = fs.readFileSync("./test.txt", "utf8");
  return content;
}
////////// * ANNOUNCEMENTS //////////////////////
// Route to get Announcements
router.get("/announcements", async (req, res) => {
  try {
    var response = await getAnnouncements();
    res.status(200).send(response);
  } catch (e) {
    handleError(e);
    res.status(400).send("Item Not Found");
  }
});

router.get("/announcements/:id", async (req, res) => {
  // Get Data from ID from Param
  try {
    const announcementId = req.params.id;

    const selectedAnnouncement = await Announcement.findById(announcementId);

    console.log(selectedAnnouncement);

    res.status(200).send(selectedAnnouncement);
  } catch (e) {
    res.status(404).send("Item Not Found");
  }
});

router.post("/announcements", async (req, res) => {
  try {
    // Get Data from body
    const bodyData = req.body;

    const title = bodyData.title;
    const body = bodyData.body;
    const date = bodyData.date;

    const newAnnouncement = new Announcement({
      title: title,
      body: body,
      date: date,
    });

    const announcement = await newAnnouncement.save();

    sendUpdateToWSClients();    

    res.status(201).send({ announcementId: announcement._id });
  } catch (e) {
    console.log(e);
    res.status(500).send("Sever Error");
  }
});

router.put("/announcements", async (req, res) => {
  try {
    // Get Data from body
    const bodyData = req.body;

    const title = bodyData.title;
    const body = bodyData.body;
    const date = bodyData.date;

    const updateValue = {
      title: title,
      body: body,
      date: date,
    };

    let id;
    
    if (bodyData.id != "") {
      id = bodyData.id;
      await Announcement.findByIdAndUpdate(id, updateValue);
    } else {
      const newAnnouncement = new Announcement(updateValue);
      id = newAnnouncement._id;
      await newAnnouncement.save();
    }

    sendUpdateToWSClients();

    res.status(201).send({ announcementId: `${id}` });
  } catch (e) {
    console.log(e);
    res.status(500).send("Sever Error");
  }
});

router.delete("/announcements/:id", async (req, res) => {
  try {
    // Get Data from body
    const id = req.params.id;

    const newAnnouncement = await Announcement.deleteOne({ _id: id });

    sendUpdateToWSClients();

    res.status(204).send("Delete Complete");
  } catch (e) {
    console.log(e);
    res.status(500).send("Sever Error");
  }
});

////////// * Announcements Stream /////////////////////////
router.ws("/stream/announcements", async function (ws, _) {
  // Push client into array
  connections.push(ws);
  console.log("Client Connected");
  // Send announcements when new connection is established
  var response = await getAnnouncements();
  ws.send(JSON.stringify(response));
});

router.ws("/stream/test", (ws, _) => {
  ws.on("message", (msg) => {
    ws.send(msg);
  });
});


async function getAnnouncements() {
  // Get all announcements from DB
  const allAnnouncements = await Announcement.find();

  let response = [];

  for (const announcementDB of allAnnouncements) {
    let announcement = {
      id: `${announcementDB._id}`,
      title: announcementDB.title,
      body: announcementDB.body,
      date: announcementDB.date,
    };
    response.push(announcement);
  };

  return response;
};

async function sendUpdateToWSClients() {
  // Get updated annoucements
  var updatedAnnouncements = await getAnnouncements();

  // Broadcast updated annoucements to all clients connected to the web socket server on announcements route
  connections.forEach((connection) => { 
    connection.send(JSON.stringify(updatedAnnouncements));
  });
}

var connections = [];

module.exports = router;
