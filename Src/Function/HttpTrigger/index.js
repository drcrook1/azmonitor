const appInsights = require("applicationinsights");

appInsights.setup(process.env["APPINSIGHTS_INSTRUMENTATIONKEY"])
    .setAutoDependencyCorrelation(true)
    .setAutoCollectRequests(true)
    .setAutoCollectPerformance(true, true)
    .setAutoCollectExceptions(true)
    .setAutoCollectDependencies(true)
    .setAutoCollectConsole(true)
    .setUseDiskRetryCaching(true)
    .setSendLiveMetrics(false)
    .setDistributedTracingMode(appInsights.DistributedTracingModes.AI_AND_W3C)
    .start();

const axios = require("axios");

/* Actual Function logic */
const httpTrigger = async function (context, req) {

    // equiv - tracked under operation id
    
    var random = Math.random()*10;
    random =  Math.round(random);
    const response = await axios.get(process.env["WebAppURL"] + random);

    context.res = {
        status: response.status
    };
};

// Entry point for the functions runtime - wrapper for app insights correlation context
module.exports = async function (context, req) {
    // Start an AI Correlation Context using the provided Function context
    const correlationContext = appInsights.startOperation(context, req);
    
    //Create blob file that contains operationId
    context.bindings.outputBlob = "Information " + correlationContext.operation.id;
    let client = appInsights.defaultClient; 
    client.trackEvent("Blob name: " + context.bindingData.sys.randGuid);
    
    // Wrap the Function runtime with correlationContext
    return appInsights.wrapWithCorrelationContext(async () => {
        const startTime = Date.now(); // Start trackRequest timer

        // Run the Function
        await httpTrigger(context, req);

        appInsights.defaultClient.flush();
    }, correlationContext)();
};