/**
 * This file is wriiten in ES6 syntax so older version nodejs can not run it.
 * For example if we want to run this code under node 4.9.1 environment,
 * we must transpile it to ES5 and then execute it. 
 */
const http = require('http');
const os = require('os');
const fs = require('fs');

const dataFile = "/var/data/id.txt";

/**
 * Check wheter the given file exists.
 */
let fileExists = (file) => {
  try {
    fs.statSync(file);
    return true;
  } catch (e) {
    return false;
  }
}

/**
 * Create a http server listening on port 8080 
 * on which we can see the content of dataFile
 * (/var/data/id.txt)
 */
http.createServer((request, response) => {
  let data = fileExists(dataFile) ? fs.readFileSync(dataFile, 'utf8') : "There is no data yet";
  response.writeHead(200);
  response.write("You've hit " + os.hostname() + "\n");
  response.end("Data stored on this pod: " + data + "\n");
}).listen(8080);
