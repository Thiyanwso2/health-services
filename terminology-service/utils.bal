import ballerinax/health.fhir.r4;
import ballerinax/health.fhir.r4.international401;
isolated function codesystemConceptsToParameters(r4:CodeSystemConcept[]|r4:CodeSystemConcept concepts) returns international401:Parameters {
    international401:Parameters parameters = {};
    if concepts is r4:CodeSystemConcept {
        parameters = {
            'parameter: [
                {name: "name", valueString: concepts.code},
                {name: "display", valueString: concepts.display}
            ]
        };

        if concepts.definition is string {
            (<international401:ParametersParameter[]>parameters.'parameter).push({name: "definition", valueString: concepts.definition});
        }

        if concepts.property is r4:CodeSystemConceptProperty[] {
            foreach var item in <r4:CodeSystemConceptProperty[]>concepts.property {
                international401:ParametersParameter result = codeSystemConceptPropertyToParameter(item);
                (<international401:ParametersParameter[]>parameters.'parameter).push(result);
            }
        }

        if concepts.designation is r4:CodeSystemConceptDesignation[] {
            foreach var item in <r4:CodeSystemConceptDesignation[]>concepts.designation {
                international401:ParametersParameter result = designationToParameter(item);
                (<international401:ParametersParameter[]>parameters.'parameter).push(result);
            }
        }
    } else {
        international401:ParametersParameter[] p = [];
        foreach r4:CodeSystemConcept item in concepts {
            p.push({name: "name", valueString: item.code},
                    {name: "display", valueString: item.display});

            if item.definition is string {
                p.push({name: "definition", valueString: item.definition});
            }

            if item.property is r4:CodeSystemConceptProperty[] {
                foreach var prop in <r4:CodeSystemConceptProperty[]>item.property {
                    international401:ParametersParameter result = codeSystemConceptPropertyToParameter(prop);
                    p.push(result);
                }
            }

            if item.designation is r4:CodeSystemConceptDesignation[] {
                foreach var desg in <r4:CodeSystemConceptDesignation[]>item.designation {
                    international401:ParametersParameter result = designationToParameter(desg);
                    (<international401:ParametersParameter[]>parameters.'parameter).push(result);
                }
            }
        }
        parameters = {'parameter: p};
    }
    return parameters;
}


isolated function codeSystemConceptPropertyToParameter(r4:CodeSystemConceptProperty property) returns international401:ParametersParameter {
    international401:ParametersParameter param = {name: "property"};
    international401:ParametersParameter[] part = [];

    if property.valueString is string {
        part.push(
            {name: "code", valueCode: property.code},
            {name: "value", valueString: property.valueString}
        );
    }

    if property.valueCoding is r4:Coding {
        part.push(
            {name: "code", valueCode: property.code},
            {name: "value", valueCoding: property.valueCoding}
        );
    }
    param.part = part;

    return param;
}

isolated function designationToParameter(r4:CodeSystemConceptDesignation designation) returns international401:ParametersParameter {
    international401:ParametersParameter param = {name: "designation"};
    international401:ParametersParameter[] part = [];

    if designation.language is string {
        part.push({name: "language", valueCode: designation.language});
    }

    if designation.value is string {
        part.push({name: "value", valueString: designation.value});
    }

    if designation.use is r4:Coding {
        part.push({name: "use", valueCoding: designation.use});
    }
    param.part = part;

    return param;
}