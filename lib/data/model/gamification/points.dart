class Points {
  String ID;
  int quantity;

  Points({this.ID, this.quantity});

  factory Points.fromJson(Map<String, dynamic> json) {
    return Points(
      ID: json['_id'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.ID;
    data['quantity'] = this.quantity;
    return data;
  }
}
