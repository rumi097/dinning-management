/// Represents a university residential hall (matches backend Hall entity).
class HallModel {
  final int id;
  final String name;

  const HallModel({
    required this.id,
    required this.name,
  });

  factory HallModel.fromJson(Map<String, dynamic> json) => HallModel(
        id: json['id'] as int,
        name: json['name'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  HallModel copyWith({int? id, String? name}) => HallModel(
        id: id ?? this.id,
        name: name ?? this.name,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HallModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'HallModel(id: $id, name: $name)';
}
