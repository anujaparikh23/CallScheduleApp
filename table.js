var Table = require('cli-table');
var dataForge = require('data-forge');
var dataFrame = dataForge
                .readFileSync("/home/cts565637/Anuja/AmexBot/Sample_Metadata.csv")
                .parseCSV()
                ;

var table = new Table({dataFrame
//  chars: { 'top': '-' , 'top-mid': '-' , 'top-left': '+' , 'top-right': '+'
//         , 'bottom': '-' , 'bottom-mid': '-' , 'bottom-left': '+' , 'bottom-right': '+'
//         , 'left': '¦' , 'left-mid': '¦' , 'mid': '-' , 'mid-mid': '+'
//         , 'right': '¦' , 'right-mid': '¦' , 'middle': '¦' }
});

//table.push(
//    ['foo', 'bar', 'baz']
//  , ['frob', 'bar', 'quuz']
//);

console.log(dataFrame.toString());