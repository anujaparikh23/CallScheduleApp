var restify = require('restify');
var builder = require('botbuilder');

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
    appId: "f079f4c0-39a6-4825-81e2-0da3a7c13b53",
    appPassword: "YSECyKR5dMeFLNUpFJzO9Ud"
});


//Bot Endpoint

var bot = new builder.UniversalBot(connector);
server.post('/api/messages', connector.listen());

//LUIS Details

var model = 'https://westus.api.cognitive.microsoft.com/luis/v2.0/apps/8802cb27-e16c-4b6b-aff7-06b9dfcda208?subscription-key=4bd3b5cc82cc4835ac5e1d3c343b600c&timezoneOffset=0&verbose=true&q=';
// This Url can be obtained by uploading or creating your model from the LUIS portal: https://www.luis.ai/

// for fixing default message issue
var recognizer = new builder.LuisRecognizer(model).onEnabled((context, callback) => {
    var enabled = context.dialogStack().length === 0;
    callback(null, enabled);
});
bot.recognizer(recognizer);

// Fix for Skype issue
  bot.use(builder.Middleware.dialogVersion({
            version: 1.0,
            message: 'Conversation restarted by a main update',
            resetCommand: /^reset/i
        }));

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
    function(session,results) {

        if (results.response) {
            var selection = results.response.entity;
             
            // route to corresponding dialogs
            switch (selection) {
                case "Yes":
                     //error on skype
                     session.send("Nice to meet you Lisa.<br/>May I know what would be your working hours for today?");
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
        session.send("Sure");
        console.log("#Inside WorkingHours Intent Dialog");

        var timeEntity = builder.EntityRecognizer.findEntity(args.intent.entities, 'builtin.datetimeV2.timerange');
        
        FromTime=JSON.stringify(timeEntity.resolution.values[0]['start']);;
        ToTime=JSON.stringify(timeEntity.resolution.values[0]['end']);;
        if (timeEntity) {
           session.send('So you will be in office from \'%s\' till \'%s\' <br/><br/>',FromTime,ToTime );
        }else
        {
           session.send("**I din't understand. Please try again**");
        }

        session.send("Please wait for a moment till the time I analyze the best target combination for you today.<br/><br/>");
        session.send("Based on target's availability, your availability and least drive time, you could visit:<br/><br/>");
        
        session.send("--**Name**---**Specialty**---**DriveTime**-----**Availability**------**Approx.Stay Time**<br/>1.     Dr.A          JKL          40 mins        10:00AM-11:30AM                10mins<br/>2.     Dr.B          KLJ          35 mins        11:00AM-1:30PM                10mins<br/>3.     Dr.C          JLK          20 mins        2:00PM-5:00PM                15mins<br/>4.     Dr.D          LJK          00 mins        2:30PM-5:00PM                10mins<br/><br/>");
       

        session.send("Also, as per your call plan, sampling guidance for today's tentative targets would look like:<br/><br/>");
         session.send("----**Name**----**Brand_X**-----**Brand_Y**----**Brand_Z**<br/>1.     Dr.A           2                 4            0<br/>2.     Dr.B           0                 2            0<br/>3.     Dr.C           0                 2            2<br/>4.     Dr.D           1                 1            1<br/>");
         
        session.endDialog();
        session.beginDialog('/MoreSuggestion');
    } 
    
]).triggerAction({
    matches: 'WorkingHours'
});




// /MoreSuggestion Dialog

bot.dialog('/MoreSuggestion', [
    function(session,next) {
        builder.Prompts.choice(session, "<br/>Lisa, I have some more suggestions for you based on your tentative targets for today. May I?", ['Yes', 'No'], {listStyle: builder.ListStyle.button
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
        session.send("Alright then. Here it goes for tied up physicians with Dr.A<br/><br/>");
        
        session.send("----**Name**------**Specialty**-----**DriveTime**------**Availability**------**Approx.Stay Time**<br/>1.     Dr.E              JKL                  00 mins        10:00AM-1:30PM               08mins<br/>2.     Dr.F              KLJ                  00 mins        09:30AM-1:00PM               10mins");
        
        session.send("With Dr.D you could also visit:<br/><br/>");
        session.send("----**Name**------**Specialty**-----**DriveTime**------**Availability**------**Approx.Stay Time**<br/>1.     Dr.G              LKJ                  00 mins        2:00PM-5:30PM              10mins");
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
                                   
        session.send("----**Name**-----**Common Connections**-----**Interest Areas**----**Events Attended**------**Planned Events**----<br/>1.     Dr.E          AA,BB,CC          XX,YY          PQ Speaker Prog,Charity Event              Event 1, Event 2<br/>2.     Dr.F          AA,EE,FF          XX,ZY          KLJ Specialty Meet,College Reunion              Event 3<br/>3.     Dr.G          none               XY,YZ          Upcoming drugs event,XYZ Summit              Event 4<br/>");
       
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

        session.send("Here you go:<br/>1.Internal Sponsored Trials:<br/>            a.Dummy Trial 1<br/>            b.Dummy Trial 2<br/>2.Third Party Trials:<br/>            a.Dummy TPT 1<br/>            b.Dummy TPT 2<br/>            c.Dummy TPT 3<br/>3.Individual Publications:<br/>            a.Dummy IP 1<br/>            b.Dummy IP 2<br/>            c.Dummy IP 3<br/>4.Joint Publications:<br/>            a.Dummy JP 1<br/>            b.Dummy JP 2");
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
        session.send("Thank you and have a wonderful time ahead !!");
        session.endConversation();
    }
]);


//AnythingElse Dialog
bot.dialog('/AnythingElse', [

function(session, args, next) {
        console.log("# Inside AnythingElse Dialog")
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
