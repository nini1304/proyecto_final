import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../config/palette.dart';
import '../../domain/models/pet.dart';
import '../../data/datasources/firebase/pet_remote_ds.dart';
import '../../data/datasources/local/breed_local_ds.dart';

class AddPetScreen extends ConsumerStatefulWidget {
  const AddPetScreen({super.key});

  @override
  ConsumerState<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends ConsumerState<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _ageController = TextEditingController();
  final _descriptionController = TextEditingController(); 

  File? _imageFile;
  String? _selectedBreed;
  final _breedController = TextEditingController();
  List<String> _breeds = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBreeds();
  }

  Future<void> _loadBreeds() async {
    final ds = BreedLocalDataSource();
    setState(() => _breeds = ds.getAllBreeds());
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<String?> _saveImageLocally(File file) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = p.basename(file.path);
    final savedImage = await file.copy('${appDir.path}/$fileName');
    return savedImage.path;
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      String? localImagePath;
      if (_imageFile != null) {
        localImagePath = await _saveImageLocally(_imageFile!);
      }

      final pet = Pet(
        id: '',
        name: _nameController.text.trim(),
        species: _speciesController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        adopted: false,
        imageUrl: null,
        localImagePath: localImagePath,
        ownerId: user?.uid ?? '',
        breed: _selectedBreed ?? _breedController.text.trim(),
        description: _descriptionController.text.trim(), 
      );

      if (_breedController.text.isNotEmpty) {
        await BreedLocalDataSource().addBreed(_breedController.text.trim());
      }

      await PetRemoteDataSource().addPet(pet);
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Mascota 🐶'),
        backgroundColor: AppColors.coralSuave,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _speciesController,
                decoration: const InputDecoration(labelText: 'Especie'),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedBreed,
                items: _breeds
                    .map((breed) => DropdownMenuItem(
                          value: breed,
                          child: Text(breed),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedBreed = value),
                decoration: const InputDecoration(labelText: 'Raza'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(labelText: 'Nueva raza (opcional)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Edad'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo),
                label: const Text('Seleccionar imagen'),
              ),
              const SizedBox(height: 10),
              if (_imageFile != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_imageFile!, height: 160),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
