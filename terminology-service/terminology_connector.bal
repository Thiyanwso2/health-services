import ballerina/http;
import ballerinax/health.fhir.r4.international401;
import ballerinax/health.fhir.r4;
import ballerinax/health.fhir.r4.terminology;
import ballerina/regex;
import ballerina/time;

public isolated function codeSystemLookUpGet(http:RequestContext ctx, http:Request request, string? id = ()) returns international401:Parameters|r4:FHIRError {

    string? system = request.getQueryParamValue("system");
    string? codeValue = request.getQueryParamValue("code");

    r4:CodeSystemConcept[]|r4:CodeSystemConcept result;
    if id is string {
        result = check terminology:codeSystemLookUp(<r4:code>codeValue, system = (check readCodeSystemById(id)).url);
    } else if system is string {
        result = check terminology:codeSystemLookUp(<r4:code>codeValue, system = system);
    } else {
        return r4:createFHIRError(
            "Can not find a CodeSystem",
            r4:ERROR,
            r4:INVALID_REQUIRED,
            diagnostic = "Either CodeSystem record or system URL should be provided as input",
            httpStatusCode = http:STATUS_BAD_REQUEST);
    }

    return codesystemConceptsToParameters(result);
}

public isolated function readCodeSystemById(string id) returns r4:CodeSystem|r4:FHIRError {
    string[] split = regex:split(id, string `\|`);
    return terminology:readCodeSystemById(split[0], split.length() > 1 ? split[1] : ());
}

public isolated function searchCodeSystem(http:Request request) returns r4:Bundle|r4:FHIRError {
    map<string[]> searchParams = request.getQueryParams();
    map<r4:RequestSearchParameter[]> params = prepareRequestSearchParameter(searchParams);

    r4:CodeSystem[] codeSystems = check terminology:searchCodeSystems(params);
    r4:BundleEntry[] entries = codeSystems.'map(c => <r4:BundleEntry>{'resource: c, search: {mode: r4:MATCH}});

    return {
        'type: r4:BUNDLE_TYPE_SEARCHSET,
        meta: {
            lastUpdated: time:utcToString(time:utcNow())
        },
        total: entries.length(),
        entry: entries
    };
}