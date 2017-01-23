var express = require('express');
var app = express();


var multer  =   require('multer');
var storage =   multer.diskStorage({
  destination: function (req, file, callback) {
    callback(null, './uploads');
  },
  filename: function (req, file, callback) {
    callback(null, file.fieldname + '-' + Date.now());
  }
});
var upload = multer({ storage : storage}).single('userPhoto');


app.post('/api/photo',function(req,res){
    upload(req,res,function(err) {
        if(err) {
            return res.end("Error uploading file.");
        }
        res.end("File is uploaded");
    });
});

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
  
    var createTable = "CREATE TABLE Patients (id INTEGER PRIMARY KEY AUTOINCREMENT, dateAdded DATETIME"
  
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
        } else if (config.options[i].type == "integerArrayCell") {
            // TODO create table for integer array cell
        } else if (config.options[i].type == "textArrayCell") {
            // TODO create table for text array cell
        }
     }
     
    createTable += ")"
     
    db.run(createTable);
    
  /*  for (j = 0; j < 10; j++) {

        var insertRow = "INSERT INTO Patients (id, dateAdded"
        
        for (i = 0; i < config.options.length; i++) {
            insertRow += ", "
            insertRow += config.options[i].columnName + " "
        }
        
        insertRow += ") VALUES (NULL, \"" + getDateTime() + "\""
        
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
        
        db.run(insertRow)
    } */
    
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
    
        var selectPatient = "SELECT id, dateAdded"
    
        for (i = 0; i < config.options.length; i++) {
            selectPatient += ", "
            selectPatient += config.options[i].columnName
        }
        
        var id = req.params.id
        selectPatient +=  " FROM Patients WHERE id=" + id

        console.log(selectPatient)
        db.all(selectPatient, function(err, rows) {
            res.send(JSON.stringify(rows[0]));
            console.log(JSON.stringify(rows));
        });
    });
    db.close();
})

// This responds a GET request
app.get('/patient/recent/', function (req, res) {
    // First name, lastname, dateAdded, and id hardcoded
    var db = new sqlite3.Database(file);
    db.serialize(function() {
        var sql = "SELECT id, dateAdded, firstName, lastName FROM Patients ORDER BY dateAdded DESC LIMIT 15";
        
        db.all(sql, function(err, rows) {
            var patients = {"patients" : rows}
            res.send(JSON.stringify(patients));
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
    
    console.log(request.body.firstName)
    console.log(request.body.lastName)
    
    var date = new Date();
        
    var insertRow = "INSERT INTO Patients (id, dateAdded"
    
    for (i = 0; i < config.options.length; i++) {
        insertRow += ", "
        insertRow += config.options[i].columnName + " "
    }
    
    insertRow += ") VALUES (NULL, \"" + getDateTime() + "\""
    
    for (i = 0; i < config.options.length; i++) {
        insertRow += ", "
        
        if (config.options[i].type == "textFieldCell") {
            insertRow += "\"" + request.body[config.options[i].columnName] + "\""
        
        } else if (config.options[i].type == "textViewCell") {
            insertRow += "\"" + request.body[config.options[i].columnName] + "\""
        
        } else if (config.options[i].type == "integerCell") {
            insertRow += request.body[config.options[i].columnName]
        
        } else if (config.options[i].type == "dateCell") {
            insertRow += "\"" + request.body[config.options[i].columnName] + "\""
        } else {
            insertRow += "\"" + request.body[config.options[i].columnName] + "\""
        }
    }
    
    insertRow += ")"
    
    db.run(insertRow)
        
//        stmt.run(
//            request.body.dateAdded, // dateAdded
//            request.body.lastSeen, // last seen
//            request.body.firstName, // first name
//            request.body.middleName,
//            request.body.lastName,
//            request.body.sex,
//            request.body.birthDate,
//            request.body.phoneNumber,
//            request.body.emailAddress,
//            request.body.familyStatus,
//            request.body.medicalIssues,
//            request.body.currentMedications,
//            request.body.previousMedicalProblems,
//            request.body.previousSurgery,
//            request.body.allergies
//        );
//        
//        stmt.finalize();
	});

    
	db.close();

    
    response.send("success");

});

function getDateTime() {

    var date = new Date();

    var hour = date.getHours();
    hour = (hour < 10 ? "0" : "") + hour;

    var min  = date.getMinutes();
    min = (min < 10 ? "0" : "") + min;

    var sec  = date.getSeconds();
    sec = (sec < 10 ? "0" : "") + sec;

    var year = date.getFullYear();

    var month = date.getMonth() + 1;
    month = (month < 10 ? "0" : "") + month;

    var day  = date.getDate();
    day = (day < 10 ? "0" : "") + day;

    return year + ":" + month + ":" + day + ":" + hour + ":" + min + ":" + sec;

}
