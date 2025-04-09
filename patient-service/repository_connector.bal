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
    baseURL: "https://ohfhirrepositorypoc-ohfhirrepositorypoc.fhir.azurehealthcareapis.com",
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

public isolated function getById(string 'resource, string id) returns r4:FHIRError|fhir:FHIRResponse {
    lock {
        fhir:FHIRResponse|fhir:FHIRError response = fhirConnectorObj->getById('resource, id);

        if response is fhir:FHIRError {
            log:printError(response.toBalString());
            return r4:createFHIRError(response.message(), r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_INTERNAL_SERVER_ERROR);
        }

        return response.clone();
    }
}

public isolated function update(json payload) returns r4:FHIRError|fhir:FHIRResponse{
    lock {
            fhir:FHIRResponse|fhir:FHIRError fhirResponse = fhirConnectorObj->update(payload.clone(), returnPreference = fhir:REPRESENTATION);

            if fhirResponse is fhir:FHIRError{
                log:printError(fhirResponse.toBalString());
                return r4:createFHIRError(fhirResponse.message(), r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_INTERNAL_SERVER_ERROR);
            }

            log:printInfo(string `Data updated successfully: ${fhirResponse.toJsonString()}`);
            return fhirResponse.clone();
    }
}

public isolated function patchResource(string 'resource, string id, json payload) returns r4:FHIRError|fhir:FHIRResponse{
    lock {
            fhir:FHIRResponse|fhir:FHIRError fhirResponse = fhirConnectorObj->patch('resource, id, payload.clone());

            if fhirResponse is fhir:FHIRError{
                log:printError(fhirResponse.toBalString());
                return r4:createFHIRError(fhirResponse.message(), r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_INTERNAL_SERVER_ERROR);
            }

            log:printInfo(string `Data patched successfully: ${fhirResponse.toJsonString()}`);
            return fhirResponse.clone();
    }
}

public isolated function delete(string 'resource, string id) returns r4:FHIRError|fhir:FHIRResponse{
    lock {
        fhir:FHIRResponse|fhir:FHIRError response = fhirConnectorObj->delete('resource, id);

        if response is fhir:FHIRError {
            log:printError(response.toBalString());
            return r4:createFHIRError(response.message(), r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_INTERNAL_SERVER_ERROR);
        }

        log:printInfo(string `Data deleted successfully: ${response.toJsonString()}`);
        return response.clone();
    }
}

public isolated function search(string 'resource, map<string[]>? searchParameters = ()) returns r4:FHIRError|fhir:FHIRResponse{
    lock {
        fhir:FHIRResponse|fhir:FHIRError response = fhirConnectorObj->search('resource, searchParameters.clone());

        if response is fhir:FHIRError {
            log:printError(response.toBalString());
            return r4:createFHIRError(response.message(), r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_INTERNAL_SERVER_ERROR);
        }
        
        return response.clone();
    }
}