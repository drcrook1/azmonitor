const axios = require("axios");

module.exports = async function (context) {
    
    // Make a GET request to the HTTP TRIGGER function that use 
    // The URL need to point to the HTT TRIGGER function
    await axios.get(process.env["FunctionAppURL"] + "/api/HttpTrigger");

    context.done();
};