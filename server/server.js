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
    db.run("CREATE TABLE Patients (id INTEGER PRIMARY KEY AUTOINCREMENT, name char(50))");

    var stmt = db.prepare("INSERT INTO Patients (id, name) VALUES (NULL, ?)");
    var staticNames = ["Bob", "John Smith", "Mr. Robot", "Eminem", "Jane", "Jim", "Megan", "Sherlock"];
    var randomVal
    for (var i = 0; i < 10; i++) {
        randomVal = Math.random() * 1000
        stmt.run(staticNames[i % staticNames.length]);
    }
    stmt.finalize();
    
        
    db.run("CREATE TABLE PatientWeights (id INTEGER PRIMARY KEY AUTOINCREMENT, weight INTEGER, patientid INTEGER)");
    
  }
  
  //var sql = "SELECT rowid AS id, name FROM Patients";
  var sql = "SELECT id, name FROM Patients";

    // Print the records as JSON
    db.all(sql, function(err, rows) {
      console.log(JSON.stringify(rows));
    });
    

});
db.close();

// This responds a GET request for the /list_user page.
app.get('/patient', function (req, res) {

    var db = new sqlite3.Database(file);
    db.serialize(function() {
        var id = req.query.id
        var sql = "SELECT name, id FROM Patients WHERE id=" + id;
        db.all(sql, function(err, rows) {
            res.send(JSON.stringify(rows));
            console.log(JSON.stringify(rows));
        });
    });
    db.close();


})

app.get('/search', function(req, res) {
	var searchInput = req.query.input;

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
app.get('/list_patient_names', function (req, res) {

    var db = new sqlite3.Database(file);
    db.serialize(function() {
        var sql = "SELECT id, name FROM Patients";
        db.all(sql, function(err, rows) {
            var patients = {"patients" : rows}
            res.send(JSON.stringify(patients));
            console.log(JSON.stringify(rows));
        });
    });
    db.close();

})

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
