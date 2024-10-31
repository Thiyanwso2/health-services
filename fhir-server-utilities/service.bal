import ballerina/http;

isolated map<json> resourceData = {};

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    isolated resource function get last\-created\-resource() returns json|error {
        lock {
            return resourceData.clone().get("lastCreated");
        }
    }

    isolated resource function post resource\-data(http:Request req) returns error? {
        json|http:ClientError jsonPayload = req.getJsonPayload();
        lock {
            if jsonPayload is json {
                resourceData["lastCreated"] = jsonPayload.clone();
            }
        }
    }
}
