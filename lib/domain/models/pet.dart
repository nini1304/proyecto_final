class Pet {
  final String id;
  final String name;
  final String species;
  final String? breed;
  final int age;
  final bool adopted;
  final String? imageUrl;
  final String? localImagePath;
  final String ownerId;
  final String? description; 

  Pet({
    required this.id,
    required this.name,
    required this.species,
    this.breed,
    required this.age,
    required this.adopted,
    this.imageUrl,
    this.localImagePath,
    required this.ownerId,
    this.description, 
  });

  factory Pet.fromMap(Map<String, dynamic> map, String id) => Pet(
        id: id,
        name: map['name'] ?? '',
        species: map['species'] ?? '',
        breed: map['breed'],
        age: map['age'] ?? 0,
        adopted: map['adopted'] ?? false,
        imageUrl: map['imageUrl'],
        localImagePath: map['localImagePath'],
        ownerId: map['ownerId'] ?? '',
        description: map['description'], 
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'species': species,
        'breed': breed,
        'age': age,
        'adopted': adopted,
        'imageUrl': imageUrl,
        'localImagePath': localImagePath,
        'ownerId': ownerId,
        'description': description, 
      };
}
