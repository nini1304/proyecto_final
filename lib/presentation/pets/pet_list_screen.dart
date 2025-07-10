import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/palette.dart';
import '../../domain/models/pet.dart';
import '../../data/datasources/firebase/pet_remote_ds.dart';
import 'pet_detail_screen.dart';

final petListProvider = FutureProvider.autoDispose<List<Pet>>((ref) async {
  final ds = PetRemoteDataSource();
  final allPets = await ds.fetchAllPets();
  return allPets.where((pet) => pet.adopted == false).toList();
});

class PetListScreen extends ConsumerStatefulWidget {
  const PetListScreen({super.key});

  @override
  ConsumerState<PetListScreen> createState() => _PetListScreenState();
}

class _PetListScreenState extends ConsumerState<PetListScreen> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.refresh(petListProvider);
  }

  @override
  Widget build(BuildContext context) {
    final petAsync = ref.watch(petListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mascotas disponibles 🐾'),
        backgroundColor: AppColors.coralSuave,
      ),
      body: petAsync.when(
        data: (pets) => ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: pets.length,
          itemBuilder: (context, index) {
            final pet = pets[index];

            ImageProvider imageProvider;

            if (pet.localImagePath != null &&
                File(pet.localImagePath!).existsSync()) {
              imageProvider = FileImage(File(pet.localImagePath!));
            } else if (pet.imageUrl != null &&
                pet.imageUrl!.startsWith('http')) {
              imageProvider = NetworkImage(pet.imageUrl!);
            } else {
              imageProvider = const AssetImage('assets/default_pet.png');
            }

            return Card(
              color: AppColors.melocotonPastel.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
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
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PetDetailScreen(pet: pet)),
                ).then((_) => ref.refresh(petListProvider)),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
