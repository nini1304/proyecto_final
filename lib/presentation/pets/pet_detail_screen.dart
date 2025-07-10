import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/pet.dart';
import '../../domain/models/adoption_request.dart';
import '../../config/palette.dart';

class PetDetailScreen extends ConsumerStatefulWidget {
  final Pet pet;

  const PetDetailScreen({super.key, required this.pet});

  @override
  ConsumerState<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends ConsumerState<PetDetailScreen> {
  bool _hasRequested = false;
  String _userRole = '';
  String? _ownerEmail;
  String? _ownerPhone;

  @override
  void initState() {
    super.initState();
    _checkRequestStatus();
    _getUserRole();
    _getOwnerContact();
  }

  Future<void> _checkRequestStatus() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final query = await FirebaseFirestore.instance
        .collection('adoption_requests')
        .where('petId', isEqualTo: widget.pet.id)
        .where('userId', isEqualTo: uid)
        .get();
    if (query.docs.isNotEmpty) {
      setState(() => _hasRequested = true);
    }
  }

  Future<void> _getUserRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (doc.exists && doc.data()!.containsKey('role')) {
      setState(() => _userRole = doc['role']);
    }
  }

  Future<void> _getOwnerContact() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.pet.ownerId)
        .get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _ownerEmail = data['email'];
        _ownerPhone = data['phone'];
      });
    }
  }

  Future<void> _sendAdoptionRequest() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final request = AdoptionRequest(
      id: '',
      petId: widget.pet.id,
      petName: widget.pet.name,
      petOwnerId: widget.pet.ownerId,
      userId: user.uid,
      userEmail: user.email ?? '',
      status: 'pendiente',
    );

    try {
      await FirebaseFirestore.instance
          .collection('adoption_requests')
          .add(request.toMap());
      setState(() => _hasRequested = true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Solicitud enviada 💌')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  ImageProvider getPetImage() {
    if (widget.pet.localImagePath != null &&
        widget.pet.localImagePath!.isNotEmpty) {
      final file = File(widget.pet.localImagePath!);
      if (file.existsSync()) return FileImage(file);
    }
    if (widget.pet.imageUrl != null && widget.pet.imageUrl!.isNotEmpty) {
      return NetworkImage(widget.pet.imageUrl!);
    }
    return const AssetImage('assets/default_pet.png');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pet.name),
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
              widget.pet.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.marronClaro,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.pet.species} ${widget.pet.breed != null ? "• ${widget.pet.breed}" : ""} • ${widget.pet.age} años',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            if (widget.pet.description != null &&
                widget.pet.description!.isNotEmpty)
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
                    widget.pet.description!,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            if (_ownerEmail != null)
              Column(
                children: [
                  const SizedBox(height: 8),
                  Text(
                    _ownerPhone != null && _ownerPhone!.isNotEmpty
                        ? 'Contacto: $_ownerEmail / $_ownerPhone'
                        : 'Contacto: $_ownerEmail',
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            const Spacer(),
            if (_userRole != 'refugio')
              ElevatedButton.icon(
                onPressed: _hasRequested ? null : _sendAdoptionRequest,
                icon: const Icon(Icons.favorite_outline),
                label: Text(
                  _hasRequested ? 'Solicitud enviada' : 'Solicitar Adopción',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasRequested
                      ? AppColors.melocotonPastel.withOpacity(0.7)
                      : AppColors.coralSuave,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
