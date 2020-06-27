class ChildCurrency {
  String ID;
  int quantity;

  ChildCurrency({this.ID, this.quantity});

  factory ChildCurrency.fromJson(Map<String, dynamic> json) {
    return ChildCurrency(
      ID: json['ID'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ID'] = this.ID;
    data['quantity'] = this.quantity;
    return data;
  }
}
