var restify = require('restify');
var builder = require('botbuilder');


//Setup for mysql connection

var mysql = require('mysql');

//For data forge
 
var dataForge = require('data-forge');

//Global Variables

var FromTime;
var ToTime;


// Setup Restify Server

var server = restify.createServer();
server.listen(process.env.port || process.env.PORT || 5604, function() {
    console.log('%s listening to %s', server.name, server.url);
});



// Create chat connector for communicating with the Bot Framework Service

var connector = new builder.ChatConnector({
    appId: "5dca0302-029a-4556-884a-2b1ec390f325",
    appPassword: "uGJay4nyTb8NJKLB9XqkrXm"

});


//Bot Endpoint

var bot = new builder.UniversalBot(connector);
//server.post('/api/messages', connector.listen());
server.post('/api/messages', connector.listen());

//LUIS Details

var model = 'https://westus.api.cognitive.microsoft.com/luis/v2.0/apps/8802cb27-e16c-4b6b-aff7-06b9dfcda208?subscription-key=4bd3b5cc82cc4835ac5e1d3c343b600c&verbose=true&timezoneOffset=0&q=';
// This Url can be obtained by uploading or creating your model from the LUIS portal: https://www.luis.ai/
//var recognizer = new builder.LuisRecognizer(model);
// for fixing default message issue
var recognizer = new builder.LuisRecognizer(model).onEnabled((context, callback) => {
    var enabled = context.dialogStack().length === 0;
    callback(null, enabled);
});
bot.recognizer(recognizer);



var con = mysql.createConnection({
 //host     : '35.154.235.29',
 host     : 'ip-172-31-11-123.ap-south-1.compute.internal',
 user     : 'cts461006',
 password : 'password-user',
 port : 3306,
 database : 'LS_Call_Plan_BOT'
});
con.connect(function(err) {
     if (err) throw err;
});


// LUIS: Greeting intent

bot.dialog('Greeting', [
    function(session) {
        builder.Prompts.text(session, "Hi! Welcome ! I am Amber Leeds , How can I assist you?");
        console.log("#Inside Greeting Intent Dialog");
        session.endDialog();
    }  
]).triggerAction({
    matches: 'Greeting'
});



function getData(con, session, cb) {
    
        con.query("SELECT * FROM ChatBot_LinkedIn_Connections", function (err, result, fields) {
                       if (err) throw err;
                      var resultJson=JSON.stringify(result);
                      //console.log(resultJson);    
                      //session.userData.resultJson=resultJson;
                      //callback(resultJson);   
                      cb(resultJson);
                      //session.save();       
                      });
     
     
        
}




// CallPlanning Dialog


bot.dialog('/CallPlanning', [
    function(session, args, next) {
        builder.Prompts.text(session, "Oh that's great! Let me look it up  for you");
        console.log("#Inside CallPlanning Intent Dialog");
        session.endDialog();
        session.beginDialog('/ConversationStart'); 
    }
]).triggerAction({
    matches: 'CallPlanning'
});





// /ConversationStart Dialog

bot.dialog('/ConversationStart', [
    function(session,next) {
        builder.Prompts.choice(session, "First, could you confirm that your employee code is 123-456?", ['Yes', 'No'], {listStyle: builder.ListStyle.button
					});
		    
        console.log("#Inside ConversationStart Dialog");
    },
    function(session, results) {
        if (results.response) {
            var selection = results.response.entity;
            // route to corresponding dialogs
            switch (selection) {
                case "Yes":
                     builder.Prompts.text(session, "Nice to meet you Lisa.<br>May I know what would be your working hours for today?");
                     break;
                case "No":
                     session.replaceDialog('/AnythingElse');
                     break;
            }
            }
            session.endDialog();
            }
]);

// LUIS: WorkingHours intent

bot.dialog('WorkingHours', [
    function(session,args,next) {
        builder.Prompts.text(session, "Sure");
        console.log("#Inside WorkingHours Intent Dialog");

        var timeEntity = builder.EntityRecognizer.findEntity(args.intent.entities, 'builtin.datetimeV2.timerange');
        
        FromTime=JSON.stringify(timeEntity.resolution.values[0]['start']);;
        ToTime=JSON.stringify(timeEntity.resolution.values[0]['end']);;
        if (timeEntity) {
           session.send('So you will be in office from \'%s\' till \'%s\' ',FromTime,ToTime );
        }else
        {
           session.send("**I din't understand. Please try again**");
        }
        session.send("Please wait for a moment till the time I analyze the best target combination for you today.<br><br>");
        session.send("Based on target's availability, your availability and least drive time, you could visit:<br><br>");
        var tableHTML="<table> <tr><th>S.No</th><th>Name</th><th>Specialty</th><th>DriveTime</th><th>Availability</th><th>Approx.Stay Time </th></tr>                                           <tr>  <td>1.</td>  <td>Dr.A</td>  <td>JKL</td>  <td>40 mins</td>  <td>10:00AM-11:30AM</td>  <td>10mins</td> </tr>                                                <tr>  <td>2.</td>  <td>Dr.B</td>  <td>KLJ</td>  <td>35 mins</td>  <td>11:00AM-1:30PM</td>   <td>10mins</td> </tr>                                                <tr>  <td>3.</td>  <td>Dr.C</td>  <td>JLK</td>  <td>20 mins</td>  <td>2:00PM-5:00PM</td>    <td>15mins</td> </tr>                                                <tr>  <td>4.</td>  <td>Dr.D</td>  <td>LJK</td>  <td>00 mins</td>  <td>2:30PM-5:00PM</td>    <td>10mins</td> </tr>                                   </table>"
        var message = {
        type: 'message',
        textFormat: 'plain', 
        text: tableHTML
    };
    session.send(message);
        session.send("Also, as per your call plan, sampling guidance for today's tentative targets would look like:<br><br>");
        session.send("<table> <tr><th>S.No</th><th>Name</th><th>Brand_X</th><th>Brand_Y</th><th>Brand_Z</th></tr>                                                                              <tr>  <td>1.</td>  <td>Dr.A</td>  <td>2</td>  <td>4</td>    <td>0</td> </tr>                                                                                     <tr>  <td>2.</td>  <td>Dr.B</td>  <td>2</td>  <td>2</td>    <td>0</td> </tr>                                                                                     <tr>  <td>3.</td>  <td>Dr.C</td>  <td>0</td>  <td>2</td>    <td>2</td> </tr>                                                                                     <tr>  <td>4.</td>  <td>Dr.D</td>  <td>1</td>  <td>1</td>    <td>1</td> </tr>    </table>");
        
        session.endDialog();
        session.beginDialog('/MoreSuggestion');
    } 
    
]).triggerAction({
    matches: 'WorkingHours'
});




// /MoreSuggestion Dialog

bot.dialog('/MoreSuggestion', [
    function(session,next) {
        builder.Prompts.choice(session, "Lisa, I have some more suggestions for you based on your tentative targets for today. May I?", ['Yes', 'No'], {listStyle: builder.ListStyle.button
					}); 
        console.log("#Inside MoreSuggestion Dialog");
    },
    function(session, results) {
        if (results.response) {
            var selection = results.response.entity;
            // route to corresponding dialogs
            switch (selection) {
                case "Yes":
                     session.send("There are two more physicians on same address as that of Dr.A and one more physician on same address as that of Dr.D.<br/><br/><br/>Although they are non-targets, but they have significant prescription writings for Brand X and Y respectively. <br/><br/>Since you are going to these addresses anyways, you might want to visit these additional physicians as it might help you in achieving your IC goals.");
                     session.replaceDialog('/MoreOptions');
                     break;
                case "No":
                     session.replaceDialog('/AnythingElse');
                     break;
            }
            }
            }
]);


// /MoreOptions Dialog

bot.dialog('/MoreOptions', [
    function(session,next) {
        builder.Prompts.choice(session, "Shall I share the list of those physicians??", ['Yes', 'No'], {listStyle: builder.ListStyle.button
					}); 
        console.log("#Inside MoreOptions Dialog");
    },
    function(session, results) {
        if (results.response) {
            var selection = results.response.entity;
            // route to corresponding dialogs
            switch (selection) {
                case "Yes":
                     session.replaceDialog('/NewPlan');
                     break;
                case "No":
                     session.replaceDialog('/AnythingElse');
                     break;
            }
            }
            session.endDialog();
            }
]);



// NewPlan Dialog


bot.dialog('/NewPlan', [
    function(session, args, next) {
       console.log("#Inside NewPlan Dialog");
        session.send("Alright then. Here it goes for tied up physicians with Dr.A<br><br>");
        session.send("<table> <tr><th>S.No</th><th>Name</th><th>Specialty</th><th>DriveTime</th><th>Availability</th><th>Approx.Stay Time </th></tr>                                           <tr>  <td>1.</td>  <td>Dr.E</td>  <td>JKL</td>  <td>00 mins</td>  <td>10:00AM-1:30PM</td>  <td>8mins</td> </tr>                                                <tr>  <td>2.</td>  <td>Dr.F</td>  <td>KLJ</td>  <td>00 mins</td>  <td>09:30AM-1:00PM</td>   <td>10mins</td> </tr>     </table>");
        
        session.send("With Dr.D you could also visit:<br><br>");
        session.send("<table> <tr><th>S.No</th><th>Name</th><th>Specialty</th><th>DriveTime</th><th>Availability</th><th>Approx.Stay Time </th></tr>                                           <tr>  <td>1.</td>  <td>Dr.G</td>  <td>LKJ</td>  <td>00 mins</td>  <td>2:00PM-5:30PM</td>  <td>10mins</td> </tr>  </table>");
    }
]);




// LUIS: CheckAddress intent

bot.dialog('CheckAddress', [
    function(session) {
        session.send("Yes ! The suggestions are based on the information present in latest extended physician universe in CRM data.");
        console.log("#Inside CheckAddress Intent Dialog");
        session.endDialog();
    }  
]).triggerAction({
    matches: 'CheckAddress'
});






// LUIS: CheckLinkedIn intent

bot.dialog('CheckLinkedIn', [
    function(session) {
        session.send("Sure. Please wait for a moment for combined connection and public information of these physicians from LinkedIn and Facebook.");
        console.log("#Inside CheckLinkedIn Intent Dialog");
        
        session.send("<table> <tr><th>Name</th><th>        Common Connections</th><th>  Interest Areas</th><th>         Events Attended (last three months)</th><th>    Planned Events</th></tr>             <tr>  <td>Dr.E</td>  <td>AA,BB,CC,DD</td>  <td>XX,YY,ZZ</td>  <td>PQ Speaker Prog, RS Charity Event..</td>  <td>Dummy Event 1, Dummy Event 2</td> </tr>                                                                                                                                                                          <tr>  <td>Dr.F</td>  <td>AA,EE,FF,GG</td>  <td>XX,ZY,YZ</td>  <td>KLJ Specialty Meet, Med College Reunion..</td>  <td>Dummy Event 3</td> </tr>                                                                                                                                                                                   <tr>  <td>Dr.G</td>  <td>none</td>  <td>XY,YZ,ZX</td>  <td>Upcoming drugs event, XYZ Summit</td>  <td>Dummy Event 4</td>   </tr> </table>");
                                     

        session.endDialog();
    }  
]).triggerAction({
    matches: 'CheckLinkedIn'
});




// LUIS: CheckPublications intent

bot.dialog('CheckPublications', [
    function(session) {
        session.send("Ok. Let me do the search for you. It might take a minute.");
        console.log("#Inside CheckPublications Intent Dialog");
        
        session.send("Here you go:<br>1.Internal Sponsored Trials:<br>            a.Dummy Trial 1<br>            b.Dummy Trial 2<br>2.Third Party Trials:<br>            a.Dummy TPT 1<br>            b.Dummy TPT 2<br>            c.Dummy TPT 3<br>3.Individual Publications:<br>            a.Dummy IP 1<br>            b.Dummy IP 2<br>            c.Dummy IP 3<br>4.Joint Publications:<br>            a.Dummy JP 1<br>            b.Dummy JP 2");
        session.endDialog();
        session.beginDialog('/AnythingElse');
    }  
]).triggerAction({
    matches: 'CheckPublications'
});



// EndDialog Dialog


bot.dialog('/EndDialog', [
    function(session, args, next) {
        console.log("Bot says bye..");
        session.endDialog("Thank you and have a wonderful time ahead !!");
    }
]);


//AnythingElse Dialog
bot.dialog('/AnythingElse', [

function(session, args, next) {
        builder.Prompts.choice(session, "Is there anything else I can help you with??", ['Yes', 'No'], {listStyle: builder.ListStyle.button
					});
    },
    function(session, results) {
        if (results.response) {
            var selection = results.response.entity;
            // route to corresponding dialogs
            switch (selection) {
                case "Yes":
                     session.replaceDialog('Greeting');
                     break;
                case "No":
                     session.replaceDialog('/EndDialog');
                     break;
            }
            }
            }
]);

//None Intent

bot.dialog('/None', [
    function(session) {

        session.send("Thanks. Have a good day.");
        session.endDialog();
    }


]) .triggerAction({
    matches: 'None'
    })
;


bot.dialog('/', function (session) {
    session.send("You said: %s", session.message.text);
});
