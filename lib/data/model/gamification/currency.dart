class Currency {
  String createdBy;
  String ID;
  int icon;
  String name;

  Currency({this.createdBy, this.ID, this.icon, this.name});

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      createdBy: json['createdBy'],
      ID: json['_id'],
      icon: json['icon'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['createdBy'] = this.createdBy;
    data['_id'] = this.ID;
    data['icon'] = this.icon;
    data['name'] = this.name;
    return data;
  }
}
