import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/pet.dart';
import '../../config/palette.dart';
import 'pet_detail_screen.dart';

class MyPetsScreen extends ConsumerWidget {
  const MyPetsScreen({super.key});

  Stream<List<Pet>> getMyPets(String uid) {
    return FirebaseFirestore.instance
        .collection('pets')
        .where('ownerId', isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Pet.fromMap(doc.data(), doc.id)).toList());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Mascotas 🐾'),
        backgroundColor: AppColors.coralSuave,
      ),
      body: StreamBuilder<List<Pet>>(
        stream: getMyPets(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final pets = snapshot.data ?? [];

          if (pets.isEmpty) {
            return const Center(child: Text('No tienes mascotas registradas 💤'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];

              ImageProvider imageProvider;
              if (pet.localImagePath != null && File(pet.localImagePath!).existsSync()) {
                imageProvider = FileImage(File(pet.localImagePath!));
              } else if (pet.imageUrl != null && pet.imageUrl!.startsWith('http')) {
                imageProvider = NetworkImage(pet.imageUrl!);
              } else {
                imageProvider = const AssetImage('assets/default_pet.png');
              }

              return Card(
                color: AppColors.melocotonPastel.withOpacity(0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: imageProvider,
                  ),
                  title: Text(
                    pet.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.marronClaro,
                    ),
                  ),
                  subtitle: Text(
                    '${pet.species} • ${pet.age} año${pet.age != 1 ? 's' : ''}'
                    '${pet.breed != null && pet.breed!.isNotEmpty ? ' • ${pet.breed}' : ''}',
                  ),
                  trailing: pet.adopted
                      ? const Icon(Icons.check_circle, color: AppColors.verdeMenta)
                      : const Icon(Icons.hourglass_empty, color: AppColors.marronClaro),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PetDetailScreen(pet: pet),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
