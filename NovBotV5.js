//Setup for mysql connection

var mysql = require('mysql');
var moment = require('moment');

//For data forge
var extend = require('extend');		 
var expect = require('chai').expect;
var assert = require('chai').assert;
var groupArray = require('group-array');
var dataForge = require('data-forge');

//Global Variables
var cust=["004","001","011"];
var commonconn=[];
var custid=[];
var ID;
//MYSQL Connection
var con = mysql.createConnection({

 host     : 'ip-172-31-11-123.ap-south-1.compute.internal',
 user     : 'cts461006',
 password : 'password-user',
 port : 3306,
 database : 'LS_Call_Plan_BOT',
 multipleStatements: true
});

con.connect(function(err) {
     if (err) throw err;
     console.log("DB connected successfully");
});

 var name = ["john"];

 var query = 'SELECT Customer_ID FROM ChatBot_Call_Activity WHERE (First_Name = "';
 query = query + name+ '")';
 
 con.query(query,function (error, results, fields) {
  if (error) throw error;
  ID=results[0].Customer_ID;
  //
  query1='SELECT Customer_ID,Individual_Publications FROM ChatBot_Individual_Publications WHERE (Customer_ID = "';
 query1 = query1 + ID+ '")';
 query2='SELECT Customer_ID,Internal_Sponsored_Trials FROM ChatBot_Internal_Sponsored_Trials WHERE (Customer_ID = "';
 query2 = query2 + ID+ '")';
 query3='SELECT Customer_ID,Joint_Publications FROM ChatBot_Joint_Publications WHERE (Customer_ID = "';
 query3 = query3 + ID+ '")';
 query4='SELECT Customer_ID,Third_Party_Trials FROM ChatBot_Third_Party_Trials WHERE (Customer_ID = "';
 query4 = query4 + ID+ '")';
// console.log(query1);
// console.log(query2);
 //console.log(query3);
 //console.log(query4);
   
 query=query1+';'+query2+';'+query3+';'+query4;

 
 con.query(query, [1, 2, 3, 4], function (error, results1, fields) {
  if (error) throw error;
  
  //console.log(results[0]);
  
  
//  var ChatBot_Individual_Publications=dataForge.fromJSON(JSON.stringify(results[0]));
//  var ChatBot_Internal_Sponsored_Trials=dataForge.fromJSON(JSON.stringify(results[1]));
//  var ChatBot_Joint_Publications=dataForge.fromJSON(JSON.stringify(results[2]));
//  var ChatBot_Third_Party_Trials=dataForge.fromJSON(JSON.stringify(results[3]));
//  
  console.log("\nIndividual Publications:\n");
  if(!results1[0].length)
  {
   console.log("No Data Found!");
  }
  else{
       for(var i=0;i<results1[0].length;i++){
          console.log((i+1)+":"+results1[0][i].Individual_Publications);
       }
  }
  
  
  console.log("\nInternal Sponsored Trials:\n");
  if(!results1[1].length)
  {
   console.log("No Data Found!");
  }
  else{
       for(var i=0;i<results1[1].length;i++){
          console.log((i+1)+":"+results1[0][i].Internal_Sponsored_Trials);
       }
  }
  
  
  console.log("\nJoint Publications:\n");
  if(!results1[2].length)
  {
   console.log("No Data Found!");
  }
  else{
       for(var i=0;i<results1[2].length;i++){
          console.log((i+1)+":"+results1[0][i].Joint_Publications);
       }
  }
       
       
  console.log("\nThird Party Trials:\n");
  if(!results1[3].length)
  {
   console.log("No Data Found!");
  }
  else{
       for(var i=0;i<results1[3].length;i++){
          console.log((i+1)+":"+results1[0][i].Third_Party_Trials);
       }
  } 
  
  });
  });
  
  
 
