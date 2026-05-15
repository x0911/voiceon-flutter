class PersonModel {
  final String id;
  final String name;

  const PersonModel({required this.id, required this.name});

  PersonModel copyWith({String? id, String? name}) {
    return PersonModel(id: id ?? this.id, name: name ?? this.name);
  }
}
