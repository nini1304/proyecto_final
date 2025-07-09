import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/models/adoption_request.dart';

class RequestRemoteDataSource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Obtener todas las solicitudes de adopción que correspondan a un refugio
  Future<List<AdoptionRequest>> fetchRequestsForShelter(String shelterId) async {
    // 1. Obtener las mascotas que pertenecen al refugio
    final petQuery = await _db
        .collection('pets')
        .where('ownerId', isEqualTo: shelterId)
        .get();

    final petIds = petQuery.docs.map((doc) => doc.id).toList();
    if (petIds.isEmpty) return [];

    // 2. Obtener las solicitudes que correspondan a esas mascotas
    final reqQuery = await _db
        .collection('adoption_requests')
        .where('petId', whereIn: petIds)
        .get();

    return reqQuery.docs
        .map((doc) => AdoptionRequest.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Crear una solicitud de adopción
  Future<void> createRequest(AdoptionRequest request) async {
    await _db.collection('adoption_requests').add(request.toMap());
  }

  /// Actualizar estado de solicitud (aceptado, rechazado, pendiente)
  Future<void> updateRequestStatus(String requestId, String newStatus) async {
    await _db.collection('adoption_requests').doc(requestId).update({
      'status': newStatus,
    });
  }

  /// Eliminar solicitud
  Future<void> deleteRequest(String requestId) async {
    await _db.collection('adoption_requests').doc(requestId).delete();
  }

  /// Obtener solicitudes enviadas por un usuario (para los clientes)
  Future<List<AdoptionRequest>> fetchRequestsByUser(String userId) async {
    final query = await _db
        .collection('adoption_requests')
        .where('userId', isEqualTo: userId)
        .get();

    return query.docs
        .map((doc) => AdoptionRequest.fromMap(doc.data(), doc.id))
        .toList();
  }
}
