import ballerina/http;
import ballerinax/health.fhir.r4;
import ballerina/log;
import ballerinax/health.fhir.r4.international401;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    isolated resource function get fhir/r4/Codesystem/[string id]/lookup(http:RequestContext ctx, http:Request request) returns json|xml|r4:FHIRError {
        log:printDebug(string `FHIR Terminology request is received. Interaction: CodeSystem Lookup with Id: ${id}`);
        international401:Parameters codeSystemLookUpResult = check codeSystemLookUpGet(ctx, request, id);
        return codeSystemLookUpResult.toJson();
    }

    isolated resource function get fhir/r4/Codesystem(http:RequestContext ctx, http:Request request) returns json|xml|r4:FHIRError {
        log:printDebug(string `FHIR Terminology request is received. Interaction: CodeSystem Search`);

        r4:Bundle codeSystem = check searchCodeSystem(request);
        return codeSystem.toJson();
    }
}
