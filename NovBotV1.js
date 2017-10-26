var restify = require('restify');
var builder = require('botbuilder');

//Global Variables

var FromTime;
var ToTime;


// Setup Restify Server

var server = restify.createServer();
server.listen(process.env.port || process.env.PORT || 5603, function() {
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
           session.send("I din't understand. Please try again");
        }
        session.endDialog(); 
    } 
    
]).triggerAction({
    matches: 'WorkingHours'
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
