import ballerinax/health.clients.fhir;
import ballerina/http;
import ballerina/log;
import ballerinax/health.fhir.r4;

http:OAuth2ClientCredentialsGrantConfig ehrSystemAuthConfig = {
    tokenUrl: "https://login.microsoftonline.com/da76d684-740f-4d94-8717-9d5fb21dd1f9/oauth2/token",
    clientId: client_id,
    clientSecret: client_secret,
    scopes: ["system/Patient.read, system/Patient.write"],
    optionalParams: {
        "resource": "https://ohfhirrepositorypoc-ohfhirrepositorypoc.fhir.azurehealthcareapis.com"
    }
};

fhir:FHIRConnectorConfig ehrSystemConfig = {
    baseURL: "https://ohfhirrepositorypoc-ohfhirrepositorypoc.fhir.azurehealthcareapis.com/",
    mimeType: fhir:FHIR_JSON,
    authConfig : ehrSystemAuthConfig
};

isolated fhir:FHIRConnector fhirConnectorObj = check new (ehrSystemConfig);

public isolated function create(json payload) returns r4:FHIRError|fhir:FHIRResponse{
    lock {
            fhir:FHIRResponse|fhir:FHIRError fhirResponse = fhirConnectorObj->create(payload.clone());

            if fhirResponse is fhir:FHIRError{
                log:printError(fhirResponse.toBalString());
                return r4:createFHIRError(fhirResponse.message(), r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_INTERNAL_SERVER_ERROR);

            }

            log:printInfo(string `Data stored successfully: ${fhirResponse.toJsonString()}`);
            return fhirResponse.clone();
    }
}
