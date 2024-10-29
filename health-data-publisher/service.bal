import ballerina/http;
import ballerinax/kafka;
import ballerina/log;


configurable string kafkaEndpoint = ?;
configurable string cacert = ?;
configurable string keyPath = ?;
configurable string certPath = ?;
configurable string topic = "health-data-feed";

final kafka:ProducerConfiguration producerConfigs = {
    securityProtocol: kafka:PROTOCOL_SSL,
    secureSocket: {protocol: {name: "SSL"}, cert: cacert, 'key: {certFile: certPath, keyFile: keyPath}}
};

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    private final kafka:Producer orderProducer;

    function init() returns error? {
        self.orderProducer = check new (kafkaEndpoint, producerConfigs);
    }

    resource function post publish(HealthDataEvent healthData) returns json|error {
        var result = self.orderProducer->send({
            topic: topic,
            value: healthData
        });
        if (result is error) {
            log:printError("Error occurred while sending the message: ",result);
        } else {
            log:printInfo("Message published successfully: ");
        }
    }
}

public type HealthDataEvent record {
    string eventId;
    string timestamp;
    string dataType?;
    string origin?;
    anydata payload?;
};
