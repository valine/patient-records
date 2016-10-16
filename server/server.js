var express = require('express');
var app = express();

app.get('/', function (req, res) {
   res.send('Hello World');
   
   console.log("hello")
})


var server = app.listen(8081, function () {
   var host = server.address().address
   var port = server.address().port
   
   console.log("Example app listening at http://%s:%s", host, port)
})

var fs = require("fs");
var file = "patient-records.db";
var exists = fs.existsSync(file);

var sqlite3 = require("sqlite3").verbose();
var db = new sqlite3.Database(file);

db.serialize(function() {
  if(!exists) {
    db.run("CREATE TABLE Patients (id INTEGER PRIMARY KEY AUTOINCREMENT, dateAdded DATETIME, lastSeen DATETIME, firstName TEXT,  middleName TEXT,  lastName TEXT, sex INTEGER, birthdate DATE, phoneNumber TEXT, emailAddress TEXT, familyStatus INTEGER, medicalIssues TEXT, currentMedications TEXT, previousMedicalProblems TEXT, previousSurgery TEXT, allergies TEXT)");

    var stmt = db.prepare("INSERT INTO Patients (id, dateAdded, lastSeen, firstName, middleName, lastName, sex, birthdate, phoneNumber, emailAddress, familyStatus, medicalIssues, currentMedications, previousMedicalProblems, previousSurgery, allergies) VALUES (NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
    
    // Create some random test data.  This should be gone in the final version
    var staticNames = ["Bob", "John Smith", "Mr. Robot", "Eminem", "Jane", "Jim", "Megan", "Sherlock", "Ann", "Max", "Rory", "Quark", "Kirk", "Enright", "Snowden", "Blender", "Bash"];
    var staticDates = ['2013-01-01 10:00:00','2009-03-05 09:00:00','2016-01-01 10:00:00','2005-01-03 10:00:00', '2005-01-03 10:00:00', '1982-01-03 10:00:00', '1763-01-03 10:00:00', '0003-01-03 10:00:00', '2031-01-03 10:00:00','2081-01-03 10:00:00']
    
    var randomVal
    for (var i = 0; i < 40; i++) {
    
        randomVal = Math.random() * 1000
        stmt.run(
            staticDates[i % staticDates.length], // dateAdded
            staticNames[i % staticDates.length], // last seen
            staticNames[i % staticNames.length], // first name
            "middle",
            "lastname",
            4,
            "birthdate",
            "1234567890",
            "luaks@valine.io",
            0,
            "unknown",
            "unknown",
            "unknown",
            "unknown",
            "unknown"
        );
    }
    
    stmt.finalize();
    db.run("CREATE TABLE PatientWeights (id INTEGER PRIMARY KEY AUTOINCREMENT, weight INTEGER, patientid INTEGER)");
    
  }
  
  //var sql = "SELECT rowid AS id, name FROM Patients";
  var sql = "SELECT id, firstname FROM Patients";

    // Print the records as JSON
    db.all(sql, function(err, rows) {
      console.log(JSON.stringify(rows));
    });

});
db.close();


//    ______     _   _            _
//    | ___ \   | | (_)          | |  
//    | |_/ /_ _| |_ _  ___ _ __ | |_ 
//    |  __/ _` | __| |/ _ \ '_ \| __|
//    | | | (_| | |_| |  __/ | | | |_ 
//    \_|  \__,_|\__|_|\___|_| |_|\__|


// This responds a GET request for the /list_user page.
app.get('/patient', function (req, res) {

    var db = new sqlite3.Database(file);
    db.serialize(function() {
        var sql = "SELECT id, firstName, dateAdded FROM Patients";
        db.all(sql, function(err, rows) {
            var patients = {"patients" : rows}
            res.send(JSON.stringify(patients));
            console.log(JSON.stringify(rows));
        });
    });
    db.close();

})

// This responds a GET request
app.get('/patient/id/:id', function (req, res) {

    var db = new sqlite3.Database(file);
    db.serialize(function() {
    
        var id = req.params.id
        var sql = "SELECT id, dateAdded, lastSeen, firstName, middleName, lastName, sex, birthdate, phoneNumber, emailAddress, familyStatus, medicalIssues, currentMedications, previousMedicalProblems, previousSurgery, allergies FROM Patients WHERE id=" + id;
        db.all(sql, function(err, rows) {
            res.send(JSON.stringify(rows[0]));
            console.log(JSON.stringify(rows));
        });
    });
    db.close();
})

// This responds a GET request
app.get('/patient/recent/', function (req, res) {

    var db = new sqlite3.Database(file);
    db.serialize(function() {
        var sql = "SELECT firstName, id, dateAdded FROM Patients ORDER BY dateAdded DESC LIMIT 15";
        db.all(sql, function(err, rows) {
            var patients = {"patients" : rows}
            res.send(JSON.stringify(patients));
            //res.send("working")
            console.log(JSON.stringify(rows));
        });
    });
    db.close();
})

//     _____                     _     
//    /  ___|                   | |    
//    \ `--.  ___  __ _ _ __ ___| |__  
//     `--. \/ _ \/ _` | '__/ __| '_ \ 
//    /\__/ /  __/ (_| | | | (__| | | |
//    \____/ \___|\__,_|_|  \___|_| |_|

app.get('/search/:input', function(req, res) {
	var searchInput = req.params.input;
	var db = new sqlite3.Database(file);
	db.serialize(function() {
		var query = "SELECT name FROM patients WHERE name LIKE \"%" + searchInput + "%\"";
		db.all(query, function(err, rows){
			res.send(JSON.stringify(rows));
		});
	});
	db.close();
});

// This responds a GET request for the /list_user page.
app.get('/patient_server', function (req, res) {
    res.send("patient-server");
    db.close();
})




app.post('/', function(request, response){
console.log("poooosttttt");
    console.log(request.body.user.name);
    console.log(request.body.user.email);
});
