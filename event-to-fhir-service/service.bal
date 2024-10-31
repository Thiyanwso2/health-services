// Copyright (c) 2023, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein is strictly forbidden, unless permitted by WSO2 in accordance with
// the WSO2 Software License available at: https://wso2.com/licenses/eula/3.2
// For specific language governing the permissions and limitations under
// this license, please see the license as well as any agreement you’ve
// entered into with WSO2 governing the purchase of this software and any
// associated services.
//
//
// AUTO-GENERATED FILE.
//
// This file is auto-generated by Ballerina.
// Developers are allowed to modify this file as per the requirement.
import ballerina/log;
import ballerinax/health.clients.fhir;
import ballerinax/health.fhir.r4;
import ballerinax/kafka;
import ballerina/http;

# Kafka configurations
configurable string groupId = ?;
configurable string topic = ?;
configurable decimal pollingInterval = 1;
configurable string kafkaEndpoint = ?;
configurable string cacert = ?;
configurable string keyPath = ?;
configurable string certPath = ?;

# FHIR server configurations
configurable string fhirServerUrl = ?;
configurable string tokenUrl = ?;
configurable string[] scopes = ?;
configurable string client_id = ?;
configurable string client_secret = ?;

# Terminology service configurations
configurable string terminologyServiceUrl = ?;

final kafka:ConsumerConfiguration consumerConfigs = {
    groupId: groupId,
    topics: [topic],
    offsetReset: kafka:OFFSET_RESET_EARLIEST,
    sessionTimeout: 45,
    pollingInterval: pollingInterval,
    securityProtocol: kafka:PROTOCOL_SSL,
    secureSocket: {protocol: {name: kafka:PROTOCOL_SSL}, cert: cacert, 'key: {certFile: certPath, keyFile: keyPath}}
};

// call terminology service
final http:Client terminologyClient = check new(terminologyServiceUrl);

service on new kafka:Listener(kafkaEndpoint, consumerConfigs) {

    function init() returns error? {
        log:printInfo("Health data consumer service started");
    }

    remote function onConsumerRecord(HealthDataEvent[] events) returns error? {
        from HealthDataEvent event in events
        where event?.payload !is ()
        do {
            log:printInfo(string `Health data event received: ${event?.payload.toJsonString()}`, event = event);
            string? dataType = event?.dataType;
            if dataType is string {
                anydata|r4:FHIRError mappedData = mapToFhir(dataType, event?.payload);
                if mappedData is r4:FHIRError {
                    log:printError("Error occurred while mapping the data: ", mappedData);
                } else {
                    log:printInfo(string `FHIR resource mapped: ${mappedData.toJsonString()}`, mappedData = mappedData.toJson());
                    r4:FHIRError|fhir:FHIRResponse response = createResource(mappedData.toJson());
                    if response is fhir:FHIRResponse {
                        log:printInfo(string `FHIR resource created: ${response.toJsonString()}`, createdResource = response.toJson());
                    }
                }
            } else {
                log:printError("Invalid data type: ", dataType);
            }
        };
    }
}

