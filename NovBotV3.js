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
});


 var query1 = 'SELECT Customer_ID,Common_Connections FROM ChatBot_LinkedIn_Connections WHERE (Customer_ID = ';
 query1 = query1 + cust.join(' OR Customer_ID = ') + ' AND Connection_HCP_Flag="Y")';
 
 var query2 = 'SELECT Customer_ID,Common_Connections FROM ChatBot_Facebook_Connections WHERE (Customer_ID = ';
 query2 = query2 + cust.join(' OR Customer_ID = ') + ' AND Connection_HCP_Flag="Y")';

 var query3 = 'SELECT Customer_ID,Interests FROM ChatBot_LinkedIn_Interest_Areas WHERE (Customer_ID = ';
 query3 = query3 + cust.join(' OR Customer_ID = ') + ')';
 
 var query4 = 'SELECT Customer_ID,Interests FROM ChatBot_Facebook_Interest_Areas WHERE (Customer_ID = ';
 query4 = query4 + cust.join(' OR Customer_ID = ') + ')';
 
 var query5 = 'SELECT Customer_ID,Events_Attended FROM ChatBot_Facebook_Events_Attended WHERE (Customer_ID = ';
 query5 = query5 + cust.join(' OR Customer_ID = ') + ')';
  
 var query6 = 'SELECT Customer_ID,Planned_Events FROM ChatBot_Facebook_Planned_Events WHERE (Customer_ID = ';
 query6 = query6 + cust.join(' OR Customer_ID = ') + ')';
 
 query=query1+';'+query2+';'+query3+';'+query4+';'+query5+';'+query6;

 
 con.query(query, [1, 2, 3, 4, 5, 6], function (error, results, fields) {
  if (error) throw error;

  
  
  var ChatBot_LinkedIn_Connections=dataForge.fromJSON(JSON.stringify(results[0]));
  var ChatBot_Facebook_Connections=dataForge.fromJSON(JSON.stringify(results[1]));
  var ChatBot_LinkedIn_Interest_Areas=dataForge.fromJSON(JSON.stringify(results[2]));
  var ChatBot_Facebook_Interest_Areas=dataForge.fromJSON(JSON.stringify(results[3]));
  var ChatBot_Facebook_Events_Attended=dataForge.fromJSON(JSON.stringify(results[4]));
  var ChatBot_Facebook_Planned_Events=dataForge.fromJSON(JSON.stringify(results[5]));
     
//Merge Connections Data
var df_merged = ChatBot_LinkedIn_Connections.concat(ChatBot_Facebook_Connections);
pairs = df_merged.toPairs();
var objects = df_merged.toArray();


 var cust=[]
 for (var i=0;i<pairs.length;i++){
cust.push(objects[i].Customer_ID)
}

CustuniqueArray = cust.filter(function(elem, pos) {
    return cust.indexOf(elem) == pos;
})
var result =[];

for(var i=0;i<CustuniqueArray.length;i++){

        var newDf = df_merged
	      .where(function (row) {
		    return row.Customer_ID == CustuniqueArray[i]
	     });
      
       var objects1 = newDf.toArray();
 var comb=[]
for (var k=0;k<objects1.length;k++){
comb.push(objects1[k].Common_Connections)
}

comb=comb.join();
 result.push({Customer_ID:CustuniqueArray[i],Common_Connections:comb});
 comb=[];
}
//console.log(df_merged.toString());
//console.log(result);

//Merge Interest Data
var df_merged2 = ChatBot_LinkedIn_Interest_Areas.concat(ChatBot_Facebook_Interest_Areas);
pairs = df_merged2.toPairs();
var objects = df_merged2.toArray();


 var cust=[]
 for (var i=0;i<pairs.length;i++){
cust.push(objects[i].Customer_ID)
}

CustuniqueArray = cust.filter(function(elem, pos) {
    return cust.indexOf(elem) == pos;
})
var result1 =[];

for(var i=0;i<CustuniqueArray.length;i++){

        var newDf = df_merged2
	      .where(function (row) {
		    return row.Customer_ID == CustuniqueArray[i]
	     });
      
       var objects1 = newDf.toArray();
 var comb=[]
for (var k=0;k<objects1.length;k++){
comb.push(objects1[k].Interests)
}

comb=comb.join();
 result1.push({Customer_ID:CustuniqueArray[i],Interests:comb});
 comb=[];
}
//console.log(df_merged2.toString());
//console.log(result1);
 
 
//Events Attended data

pairs = ChatBot_Facebook_Events_Attended.toPairs();
var objects = ChatBot_Facebook_Events_Attended.toArray();


 var cust=[]
 for (var i=0;i<pairs.length;i++){
cust.push(objects[i].Customer_ID)
}

CustuniqueArray = cust.filter(function(elem, pos) {
    return cust.indexOf(elem) == pos;
})
var result2 =[];

for(var i=0;i<CustuniqueArray.length;i++){

        var newDf = ChatBot_Facebook_Events_Attended
	      .where(function (row) {
		    return row.Customer_ID == CustuniqueArray[i]
	     });
      
       var objects1 = newDf.toArray();
 var comb=[]
for (var k=0;k<objects1.length;k++){
comb.push(objects1[k].Events_Attended)
}

comb=comb.join();
 result2.push({Customer_ID:CustuniqueArray[i],Events_Attended:comb});
 comb=[];
}
//console.log(ChatBot_Facebook_Events_Attended.toString());
//console.log(result2);


//Planned Events data

pairs = ChatBot_Facebook_Planned_Events.toPairs();
var objects = ChatBot_Facebook_Planned_Events.toArray();


 var cust=[]
 for (var i=0;i<pairs.length;i++){
cust.push(objects[i].Customer_ID)
}

CustuniqueArray = cust.filter(function(elem, pos) {
    return cust.indexOf(elem) == pos;
})
var result3 =[];

for(var i=0;i<CustuniqueArray.length;i++){

        var newDf = ChatBot_Facebook_Planned_Events
	      .where(function (row) {
		    return row.Customer_ID == CustuniqueArray[i]
	     });
      
       var objects1 = newDf.toArray();
 var comb=[]
for (var k=0;k<objects1.length;k++){
comb.push(objects1[k].Planned_Events)
}

comb=comb.join();
 result3.push({Customer_ID:CustuniqueArray[i],Planned_Events:comb});
 comb=[];
}
//console.log(ChatBot_Facebook_Planned_Events.toString());
//console.log(result3);

 
// var objects = df_merged.toArray();
var distinctDataFrame = df_merged.sequentialDistinct(function (row) {
		return row.Customer_ID,row.Common_Connections;
	});



//Create Dataframes Again


var Connections=dataForge.fromJSON(JSON.stringify(result));
var Interests=dataForge.fromJSON(JSON.stringify(result1));
var Events_Attended=dataForge.fromJSON(JSON.stringify(result2));
var Planned_Events=dataForge.fromJSON(JSON.stringify(result3));


 var df_merged3 = Events_Attended.joinOuter(
		Planned_Events,
		left => left.Customer_ID,
		right => right.Customer_ID,
		(left, right) => {
   var output = {};
                        if (left) {
                            output.Customer_ID = left.Customer_ID;
                            output.Events_Attended = left.Events_Attended;                    
                        }
                        if (right) {
                            output.Customer_ID = right.Customer_ID;
                            output.Planned_Events = right.Planned_Events;                         
                        }
			return output;
     } 
)
;


 var df_merged4 = Connections.joinOuter(
		Interests,
		left => left.Customer_ID,
		right => right.Customer_ID,
		(left, right) => {
   var output = {};
                        if (left) {
                            output.Customer_ID = left.Customer_ID;
                            output.Common_Connections = left.Common_Connections;                    
                        }
                        if (right) {
                            output.Customer_ID = right.Customer_ID;
                            output.Interests = right.Interests;                         
                        }
			return output;
     } 
)
;


 var df_merged5 = df_merged4.joinOuter(
		df_merged3,
		left => left.Customer_ID,
		right => right.Customer_ID,
		(left, right) => {
   var output = {};
                        if (left) {
                            output.Customer_ID = left.Customer_ID;
                            output.Common_Connections = left.Common_Connections;  
                            output.Interests = left.Interests;                  
                        }
                        if (right) {
                            output.Customer_ID = right.Customer_ID;
                            output.Events_Attended = right.Events_Attended;
                            output.Planned_Events = right.Planned_Events;                         
                        }
			return output;
     } 
)
;

//console.log(df_merged5.toString());

//df_merged5.asCSV().writeFileSync('combined.csv');

});




