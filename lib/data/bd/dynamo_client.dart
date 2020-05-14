/// Adapted from aws_client project
/// Copyright aws_client contributors
/// https://github.com/agilord/aws_client/

import 'package:fokus/utils/dynamo_type_mapper.dart';
import 'dynamo_driver.dart';

class DynamoClient {
  final DynamoDB _dynamoDB;

  DynamoClient({@required String region, DynamoDB dynamoDB, AwsClientCredentials credentials, String endpointUrl, Client client})
      : _dynamoDB = dynamoDB ?? DynamoDB(region: region, credentials: credentials, endpointUrl: endpointUrl, client: client);

  Future<GetResponse> get({
    @required String tableName,
    @required Map<String, dynamic> key,
    List<String> attributesToGet,
    bool consistentRead,
    Map<String, String> expressionAttributeNames,
    String projectionExpression,
    ReturnConsumedCapacity returnConsumedCapacity,
  }) async {
    final getItemOutput = await _dynamoDB.getItem(
        key: key.fromJsonToAttributeValue(),
        tableName: tableName,
        attributesToGet: attributesToGet,
        consistentRead: consistentRead,
        expressionAttributeNames: expressionAttributeNames,
        projectionExpression: projectionExpression,
        returnConsumedCapacity: returnConsumedCapacity);
    return GetResponse(
      getItemOutput.consumedCapacity,
      getItemOutput.item.toJson(),
    );
  }
}

class GetResponse {
  final ConsumedCapacity consumedCapacity;
  final Map<String, dynamic> item;

  GetResponse(this.consumedCapacity, this.item);
}
