import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/adoption_request.dart';
final requestControllerProvider = Provider((ref) => RequestController());

class RequestController {
  final _collection = FirebaseFirestore.instance.collection('adoption_requests');
  final _petsCollection = FirebaseFirestore.instance.collection('pets');

  Future<List<AdoptionRequest>> fetchRequestsForShelter() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    // Obtener IDs de mascotas del refugio actual
    final petQuery = await _petsCollection.where('ownerId', isEqualTo: uid).get();
    final petIds = petQuery.docs.map((doc) => doc.id).toList();

    if (petIds.isEmpty) return [];

    final reqQuery = await _collection.where('petId', whereIn: petIds).get();

    return reqQuery.docs.map((doc) {
      final data = doc.data();
      return AdoptionRequest.fromMap(data, doc.id);
    }).toList();
  }
  Future<void> updateStatus(String requestId, String newStatus) async {
    try {
      await _collection.doc(requestId).update({'status': newStatus});
    } catch (e) {
      throw Exception('Error al actualizar estado: $e');
    }
  }

  Future<void> deleteRequest(String requestId) async {
    try {
      await _collection.doc(requestId).delete();
    } catch (e) {
      throw Exception('Error al eliminar solicitud: $e');
    }
  }
}