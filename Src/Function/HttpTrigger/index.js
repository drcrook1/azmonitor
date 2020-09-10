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

    try {
        await axios.get(process.env["WebAppURL"] + random);
        context.res = {
            status: 200,
            body: "All Good Captain!"
        };
    } catch(err)
    {
        console.log("Random Item Not Found!");
        context.res = {
            status: 404,
            body: "Not Found!"
        };
    }


    context.done();
};

// Entry point for the functions runtime - wrapper for app insights correlation context
module.exports = async function (context, req) {
    // Start an AI Correlation Context using the provided Function context
    const correlationContext = appInsights.startOperation(context, req);
    
    //Create blob file that contains operationId
    context.bindings.outputBlob = "Information " + correlationContext.operation.id;
    
    // Wrap the Function runtime with correlationContext
    return appInsights.wrapWithCorrelationContext(async () => {
        const startTime = Date.now(); // Start trackRequest timer

        // Run the Function
        await httpTrigger(context, req);

        appInsights.defaultClient.trackRequest({
            name: context.req.method + " " + context.req.url,
            resultCode: context.res.status,
            success: true,
            url: req.url,
            duration: Date.now() - startTime,
            id: correlationContext.operation.parentId,
            properties: {
                blob_location: "correlationContext.operation.id" + ".txt"
                }
        });

        appInsights.defaultClient.trackEvent(
            {
                name: "HttpTriggeredEvent",
                resultCode: context.res.status,
                success: true,
                url: req.url,
                duration: Date.now() - startTime,
                id: correlationContext.operation.parentId,
                properties: {
                    blob_location: "correlationContext.operation.id" + ".txt"
                    }
            });

        appInsights.defaultClient.flush();
    }, correlationContext)();
};