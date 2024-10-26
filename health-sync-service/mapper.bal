import ballerinax/health.fhir.r4;
import ballerinax/health.fhir.r4.uscore501;

public isolated function mapData(CustomPatient payload) returns uscore501:USCorePatientProfile => {
    name: [
        {
            given: [payload.firstName],
            family: payload.lastName
        }
    ],
    meta: {
        versionId: payload.'version,
        lastUpdated: payload.lastUpdatedOn,
        'source: payload.originSource
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

        }
};
