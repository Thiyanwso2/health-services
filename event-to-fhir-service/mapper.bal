import ballerina/http;
import ballerinax/health.fhir.r4;
import ballerinax/health.fhir.r4.uscore501;
import ballerinax/health.fhir.r4.validator;

# Mapper function to map health data to FHIR resources
#
# + dataType - health data type
# + payload - payload to be mapped
# + return - mapped FHIR resource or error
public isolated function mapToFhir(string dataType, anydata payload) returns anydata|r4:FHIRError {
    match dataType {
        "patient_data" => {
            Patient|error patientData = payload.cloneWithType();
            if patientData is error {
                return r4:createFHIRError("Error occurred while cloning the payload", r4:ERROR, r4:INVALID);
            }
            uscore501:USCorePatientProfile fhirPayload = mapPatient(patientData);
            r4:FHIRValidationError? validate = validator:validate(fhirPayload, uscore501:USCorePatientProfile);
            if validate is r4:FHIRValidationError {
                return r4:createFHIRError(validate.message(), r4:ERROR, r4:INVALID, cause = validate.cause(), errorType = r4:VALIDATION_ERROR, httpStatusCode = http:STATUS_BAD_REQUEST);
            }
            return fhirPayload;
        }
        _ => {
            return r4:createFHIRError("Invalid data type", r4:ERROR, r4:INVALID);
        }
    }
}

# Dedicated function to map patient data to US Core Patient Profile
#
# + payload - patient data in custom format
# + return - US Core Patient Profile
public isolated function mapPatient(Patient payload) returns uscore501:USCorePatientProfile => {
    name: [
        {
            given: [payload.firstName],
            family: payload.lastName
        }
    ],
    meta: {
        versionId: payload.'version,
        lastUpdated: payload.lastUpdatedOn,
        'source: payload.originSource,
        profile: [uscore501:PROFILE_BASE_USCOREPATIENTPROFILE]
    },
    text: {
        div: payload.description.details ?: "",
        status: <r4:StatusCode>payload.description.status

    },
    gender: <uscore501:USCorePatientProfileGender>payload.gender
,
    identifier: [
        {system: payload.identifiers[0].id_type.codes[0].system_source, value: payload.identifiers[0].id_value}
    ],
    address: from var locatoionDetailItem in payload.locatoionDetail
        select {
            country: locatoionDetailItem.nation,
            city: locatoionDetailItem.town,
            district: locatoionDetailItem.region,
            state: locatoionDetailItem.province,
            postalCode: locatoionDetailItem.zipCode,
            id: locatoionDetailItem.identifier
        },
    id: payload.patientId
};

// public isolated function mapGender(string input) returns r4:CodeableConceptExtension {
//     string mappedCode;
//     match input {
//         "male" => {
//             mappedCode = "male";
//         }
//         "female" => {
//             mappedCode = "female";
//         }
//         "other" => {
//             mappedCode = "other";
//         }
//         "unknown" => {
//             mappedCode = "unknown";
//         }
//         "M" => {
//             mappedCode = "male";
//         }
//         "F" => {
//             mappedCode = "female";
//         }
//         "O" => {
//             mappedCode = "other";
//         }
//         _ => {
//             mappedCode = "unknown";
//         }
//     }

//     //call terminology service
//     http:Response|http:ClientError unionResult = terminologyClient->/CodeSystem/administrative\-gender/lookup(code = mappedCode);
    
//     r4:CodeableConceptExtension genderExtension = {
//         url: "http://hl7.org/fhir/administrative-gender",
//         valueCodeableConcept: {
//             coding: [
//                 {
//                     system: "http://hl7.org/fhir/administrative-gender"
//                 }
//             ]
//         }
//     };

// }
