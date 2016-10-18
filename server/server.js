var express = require('express');
var app = express();

app.get('/', function (req, res) {
   res.send('Hello World');
   
   console.log("hello")
})


var server = app.listen(8081, function () {
   var host = server.address().address
   var port = server.address().port
   
   console.log("Patient Records listening at http://%s:%s", host, port)
})
var bodyParser = require('body-parser')

app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

var config = require('../patient-attributes.json');

var fs = require("fs");
var file = "patient-records.db";
var exists = fs.existsSync(file);

var sqlite3 = require("sqlite3").verbose();
var db = new sqlite3.Database(file);

db.serialize(function() {
  if(!exists) {
  
    var createTable = "CREATE TABLE Patients (id INTEGER PRIMARY KEY AUTOINCREMENT"
  
     for (i = 0; i < config.options.length; i++) {
        createTable += ", "
        createTable += config.options[i].columnName + " "
        
        if (config.options[i].type == "textFieldCell") {
            createTable += "TEXT"
        
        } else if (config.options[i].type == "textViewCell") {
            createTable += "TEXT"
        
        } else if (config.options[i].type == "integerCell") {
            createTable += "INTEGER"
        
        } else if (config.options[i].type == "dateCell") {
            createTable += "DATETIME"
        }
     }
     
    createTable += ")"
     
    db.run(createTable);
    
    var insertRow = "INSERT INTO Patients (id"
    
    for (i = 0; i < config.options.length; i++) {
        insertRow += ", "
        insertRow += config.options[i].columnName + " "
    }
    
    insertRow += ") VALUES (NULL"
    
    for (i = 0; i < config.options.length; i++) {
        insertRow += ", "
        
        if (config.options[i].type == "textFieldCell") {
            insertRow += "\"" + config.options[i].defaultValue + "\""
        
        } else if (config.options[i].type == "textViewCell") {
            insertRow += "\"" + config.options[i].defaultValue + "\""
        
        } else if (config.options[i].type == "integerCell") {
            insertRow += config.options[i].defaultValue
        
        } else if (config.options[i].type == "dateCell") {
            insertRow += "\"" + config.options[i].defaultValue + "\""
        } else {
            insertRow += "\"" + config.options[i].defaultValue + "\""
        }
    }
    
    insertRow += ")"
    
    console.log(insertRow)
    
    db.run(insertRow)
    
    db.run("CREATE TABLE PatientWeights (id INTEGER PRIMARY KEY AUTOINCREMENT, weight INTEGER, patientid INTEGER)");
  }
  
    var sql = "SELECT id, firstName FROM Patients";

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
		var query = "SELECT id, firstName FROM patients WHERE firstName LIKE \"%" + searchInput + "%\"";
		db.all(query, function(err, rows){
			res.send(JSON.stringify(rows));
		})
	});
	db.close();
});

// This responds a GET request for the /list_user page.
app.get('/patient_server', function (req, res) {
    res.send("patient-server");
    db.close();
})


app.post('/patient/add', function(request, response){

	var db = new sqlite3.Database(file);
	db.serialize(function() {
    
        var stmt = db.prepare("INSERT INTO Patients (id, dateAdded, lastSeen, firstName, middleName, lastName, sex, birthdate, phoneNumber, emailAddress, familyStatus, medicalIssues, currentMedications, previousMedicalProblems, previousSurgery, allergies) VALUES (NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
        console.log("post")
        console.log(request.body.firstName)
        console.log(request.body.lastName)
        
        stmt.run(
            request.body.dateAdded, // dateAdded
            request.body.lastSeen, // last seen
            request.body.firstName, // first name
            request.body.middleName,
            request.body.lastName,
            request.body.sex,
            request.body.birthDate,
            request.body.phoneNumber,
            request.body.emailAddress,
            request.body.familyStatus,
            request.body.medicalIssues,
            request.body.currentMedications,
            request.body.previousMedicalProblems,
            request.body.previousSurgery,
            request.body.allergies
        );
        
        stmt.finalize();
	});

    
	db.close();

    
    response.send("success");

});
