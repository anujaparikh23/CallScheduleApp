'use strict'
 
const importer = require('node-mysql-importer')
 
importer.config({
    'host': 'ip-172-31-11-123.ap-south-1.compute.internal',
    'user': 'cts461006',
    'password': 'password-user',
    'database': 'aimcognitive'
})
 
importer.importSQL('world.sql').then( () => {
    console.log('all statements have been executed')
}).catch( err => {
    console.log(`error: ${err}`)
})