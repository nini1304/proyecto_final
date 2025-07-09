import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/palette.dart';

class RequestListScreen extends ConsumerStatefulWidget {
  const RequestListScreen({super.key});

  @override
  ConsumerState<RequestListScreen> createState() => _RequestListScreenState();
}

class _RequestListScreenState extends ConsumerState<RequestListScreen> {
  String _statusFilter = 'pendiente';

  Future<String?> getUserRole(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.exists ? doc['role'] as String : null;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getRequestsStream(String uid, String role) {
    final requests = FirebaseFirestore.instance.collection('adoption_requests');

    if (role == 'refugio') {
      return requests
          .where('petOwnerId', isEqualTo: uid)
          .where('status', isEqualTo: _statusFilter)
          .snapshots();
    } else {
      return requests.where('userId', isEqualTo: uid).snapshots();
    }
  }

  Future<void> updateStatus(String requestId, String newStatus, String petId) async {
    final firestore = FirebaseFirestore.instance;

    await firestore.collection('adoption_requests').doc(requestId).update({
      'status': newStatus,
    });

    if (newStatus == 'aceptado') {
      await firestore.collection('pets').doc(petId).update({
        'adopted': true,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return FutureBuilder<String?>(
      future: getUserRole(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final role = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text(role == 'refugio'
                ? 'Solicitudes Recibidas 📩'
                : 'Mis Solicitudes 💌'),
            backgroundColor: AppColors.coralSuave,
            actions: role == 'refugio'
                ? [
                    DropdownButton<String>(
                      value: _statusFilter,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.filter_list, color: Colors.white),
                      dropdownColor: AppColors.melocotonPastel,
                      items: const [
                        DropdownMenuItem(value: 'pendiente', child: Text('Pendientes')),
                        DropdownMenuItem(value: 'aceptado', child: Text('Aceptadas')),
                        DropdownMenuItem(value: 'rechazado', child: Text('Rechazadas')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _statusFilter = value);
                        }
                      },
                    )
                  ]
                : null,
          ),
          body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: getRequestsStream(uid, role),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return const Center(
                  child: Text('No hay solicitudes aún 💤'),
                );
              }

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data();
                  final requestId = docs[index].id;
                  final petId = data['petId'] ?? '';
                  final petName = data['petName'] ?? 'Mascota';
                  final userEmail = data['userEmail'] ?? 'Desconocido';
                  final status = data['status'] ?? 'pendiente';

                  return Card(
                    margin: const EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text('🐶 $petName'),
                      subtitle: Text('Solicitado por: $userEmail'),
                      trailing: role == 'refugio' && status == 'pendiente'
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check_circle, color: Colors.green),
                                  onPressed: () => updateStatus(requestId, 'aceptado', petId),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel, color: Colors.red),
                                  onPressed: () => updateStatus(requestId, 'rechazado', petId),
                                ),
                              ],
                            )
                          : Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: status == 'aceptado'
                                    ? Colors.green
                                    : status == 'rechazado'
                                        ? Colors.red
                                        : Colors.orange,
                              ),
                            ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
