class ChildReward {
  int cost;
  int date;
  String ID;
  int quantity;

  ChildReward({this.cost, this.date, this.ID, this.quantity});

  factory ChildReward.fromJson(Map<String, dynamic> json) {
    return ChildReward(
      cost: json['cost'],
      date: json['date'],
      ID: json['ID'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cost'] = this.cost;
    data['date'] = this.date;
    data['ID'] = this.ID;
    data['quantity'] = this.quantity;
    return data;
  }
}
