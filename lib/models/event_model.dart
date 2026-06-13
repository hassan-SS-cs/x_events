class EventModel {
  final String id;
  final String title;
  final String introduction;
  final List<String> images;
  bool isRead;


  EventModel({
    required this.id,
    required this.title,
    required this.introduction,
    required this.images,
    this.isRead = false,
  });


  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'].toString(),
      title: json['title'],
      introduction: json['introduction'],
      images: List<String>.from(json['images']),
    );
  }
}