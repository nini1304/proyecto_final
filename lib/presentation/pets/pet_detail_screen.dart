import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/pet.dart';
import '../../domain/models/adoption_request.dart';
import '../../config/palette.dart';

class PetDetailScreen extends ConsumerWidget {
  final Pet pet;

  const PetDetailScreen({super.key, required this.pet});

  Future<void> sendAdoptionRequest(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final request = AdoptionRequest(
      id: '',
      petId: pet.id,
      petName: pet.name,
      petOwnerId: pet.ownerId,
      userId: user.uid,
      userEmail: user.email ?? '',
      status: 'pendiente',
    );

    try {
      await FirebaseFirestore.instance
          .collection('adoption_requests')
          .add(request.toMap());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud enviada 💌')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  ImageProvider getPetImage() {
    if (pet.localImagePath != null && pet.localImagePath!.isNotEmpty) {
      final file = File(pet.localImagePath!);
      if (file.existsSync()) return FileImage(file);
    }
    if (pet.imageUrl != null && pet.imageUrl!.isNotEmpty) {
      return NetworkImage(pet.imageUrl!);
    }
    return const AssetImage('assets/default_pet.png');
  }

  Future<String?> fetchOwnerEmail(String ownerId) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(ownerId).get();
    if (doc.exists && doc.data()!.containsKey('email')) {
      return doc['email'];
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
        backgroundColor: AppColors.coralSuave,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image(
                image: getPetImage(),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              pet.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.marronClaro,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${pet.species} ${pet.breed != null ? "• ${pet.breed}" : ""} • ${pet.age} años',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            if (pet.description != null && pet.description!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.marronClaro,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pet.description!,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            FutureBuilder<String?>(
              future: fetchOwnerEmail(pet.ownerId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 24, child: CircularProgressIndicator());
                }
                final email = snapshot.data;
                if (email == null) return const SizedBox();
                return Column(
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Contacto: $email',
                      style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                    ),
                  ],
                );
              },
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => sendAdoptionRequest(context),
              icon: const Icon(Icons.favorite_outline),
              label: const Text('Solicitar Adopción'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.coralSuave,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
