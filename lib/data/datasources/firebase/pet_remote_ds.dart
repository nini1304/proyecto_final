import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/models/pet.dart';

class PetRemoteDataSource {
  final _db = FirebaseFirestore.instance;

  Future<List<Pet>> fetchAllPets() async {
  final query = await _db
      .collection('pets')
      .where('adopted', isEqualTo: false) // 🔥 Solo no adoptadas
      .get();

  return query.docs
      .map((doc) => Pet.fromMap(doc.data(), doc.id))
      .toList();
}

  Future<void> addPet(Pet pet) async {
    await _db.collection('pets').add(pet.toMap());
  }

  Future<Pet?> getPetById(String id) async {
    final doc = await _db.collection('pets').doc(id).get();
    if (doc.exists) {
      return Pet.fromMap(doc.data()!, doc.id);
    }
    return null;
  }
}