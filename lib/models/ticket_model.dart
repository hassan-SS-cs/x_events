class TicketModel {
  final String id;
  final String name;
  final String type;
  final String imagePath;
  final DateTime createdAt;
  final String seat;

  TicketModel({
    required this.id,
    required this.name,
    required this.type,
    required this.imagePath,
    required this.createdAt,
    required this.seat,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'].toString(),
      name: json['name'],
      type: json['type'],
      imagePath: json['imagePath'],
      createdAt: DateTime.parse(json['createdAt']),
      seat: json['seat'],
    );
  }
}
