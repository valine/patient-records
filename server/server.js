var express = require('express');
var app = express();

var multer  = require('multer')
//var upload = multer({ dest: 'uploads/' })

const crypto = require('crypto');
var mime = require('mime');
var app = express()
var fs = require('fs');
var path = require('path')


var storage = multer.diskStorage({
                                 destination: function (req, file, cb) {
                                 cb(null, 'uploads/')
                                 },
                                 filename: function (req, file, cb) {
                                 
                                 cb(null, req.body.id + '.' + mime.extension(file.mimetype));
                                 
                                 }
                                 });
var upload = multer({ storage: storage });

app.post('/photo', upload.single('file'), function (req, res, next) {
         
         
  
         console.log("photo uploaded")
         console.log(req.body.id + " for id")
         

          res.send("sucess")
         
         })

var storageSmall = multer.diskStorage({
                                 destination: function (req, file, cb) {
                                 cb(null, 'uploads/')
                                 },
                                 filename: function (req, file, cb) {
                                 
                                 cb(null, req.body.id + '-small.' + mime.extension(file.mimetype));
                                 
                                 }
                                 });

var uploadSmall = multer({ storage: storageSmall });

app.post('/photosmall', uploadSmall.single('file'), function (req, res, next) {
         

         
         
         console.log("photo uploaded")
         console.log(req.body.id + " for id")
         
         
         res.send("sucess")
         
         })



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

// This responds a GET request for the /list_user page.
app.get('/patientrecords', function (req, res) {
        
        res.send("working")
        
    })


// This responds a GET request for the /list_user page.
app.get('/config', function (req, res) {

        res.send(config)
        
        })

app.get('/patient/photo/:id', function (req, res) {
        res.sendFile('uploads/' + req.params.id + '.png', { root: __dirname });
});

app.get('/patient/photosmall/:id', function (req, res) {
        res.sendFile('uploads/' + req.params.id + '-small.png', { root: __dirname });
        });

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
//            console.log(JSON.stringify(rows));
        });
    });
    db.close();

})

// This responds a GET request
app.get('/patient/mostrecent/', function (req, res) {
        // First name, lastname, dateAdded, and id hardcoded
        var db = new sqlite3.Database(file);
        db.serialize(function() {
                     var sql = "SELECT id, dateAdded, firstName, lastName FROM Patients ORDER BY dateAdded DESC LIMIT 1";
                     
                     db.all(sql, function(err, rows) {
                            var patients = {"patients" : rows}
                            res.send(JSON.stringify(patients));
                            //            console.log(JSON.stringify(rows));
                            });
                     });
        db.close();
        
        })

app.post('/patient/update', function(request, response, body) {
         try {
         var db = new sqlite3.Database(file);
         db.serialize(function() {
                      
                      console.log(request.body.firstName)
                      console.log(request.body.lastName)
                      
                      var date = new Date();
                      
                      var insertRow = "UPDATE Patients set "
                      
                      insertRow += config.options[0].columnName + " = \""
                      insertRow += request.body[config.options[0].columnName]

                      
                      for (i = 1; i < config.options.length; i++) {
                      console.log(insertRow);
                      insertRow += "\", "
                      insertRow += config.options[i].columnName + " = \""
                      insertRow += request.body[config.options[i].columnName]
                      }
                      
                      insertRow += "\" WHERE id = "
                      insertRow += request.body["id"]
                      insertRow += ";"
                      
                      try {
                      db.run(insertRow)
                      } catch (err) {
                      
                      response.send("error");
                      
                      }
                      
        });
         db.close();
        response.send("success");
         } catch (err) {
         
         
         response.send("error");
         }


        
});

app.delete('/patient/id/:id', function (req, res) {
           
           var db = new sqlite3.Database(file);
           db.serialize(function() {
                        
                        
                        var id = req.params.id
                        var deletePatient =  "DELETE FROM Patients WHERE id=" + id
                        
                        console.log(deletePatient)
                        db.all(deletePatient, function(err, rows) {
                               console.log(JSON.stringify(rows));
                               });
                        });
           db.close();

           
           
           res.send('success')
    })


app.post('/patient/add', function(request, response){
         try {
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
                      insertRow += "\"" + request.body[config.options[i].columnName].replaceAll("\"", "\"\"") + "\""
                      
                      } else if (config.options[i].type == "textViewCell") {
                      insertRow += "\"" + request.body[config.options[i].columnName].replaceAll("\"", "\"\"")  + "\""
                      
                      } else if (config.options[i].type == "integerCell") {
                      insertRow += request.body[config.options[i].columnName]
                      
                      } else if (config.options[i].type == "dateCell") {
                      insertRow += "\"" + request.body[config.options[i].columnName] + "\""
                      } else {
                      insertRow += "\"" + request.body[config.options[i].columnName].replaceAll("\"", "\"\"") + "\""
                      }
                      }
                      
                      insertRow += ")"
                      
                      db.run(insertRow)
                      
         });
         
         
         db.close();
         
         
         response.send("success"); }
         
         
         catch(err) {
         
         response.send("error");
         
         }
         
         });

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
		var query = "SELECT id, dateAdded, firstName, lastName FROM Patients WHERE firstName LIKE \"%" + searchInput + "%\" OR lastName LIKE \"%" + searchInput + "%\"";
		db.all(query, function(err, rows){
			var patients = {"patients" : rows}
            		res.send(JSON.stringify(patients));
		})
	});
	db.close();
});

// This responds a GET request for the /list_user page.
app.get('/patient_server', function (req, res) {
    res.send("patient-server");
    db.close();
})

String.prototype.replaceAll = function(search, replacement) {
    var target = this;
    return target.split(search).join(replacement);
};

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
