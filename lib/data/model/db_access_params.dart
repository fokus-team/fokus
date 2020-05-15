class DbAccessConfig {
  String accessKey;
  String region;
  String secretKey;

  DbAccessConfig({this.accessKey, this.region, this.secretKey});

  factory DbAccessConfig.fromJson(Map<String, dynamic> json) {
    return DbAccessConfig(
      accessKey: json['accessKey'],
      region: json['region'],
      secretKey: json['secretKey'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['accessKey'] = this.accessKey;
    data['region'] = this.region;
    data['secretKey'] = this.secretKey;
    return data;
  }
}
