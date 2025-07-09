import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../config/palette.dart';
import '../pets/add_pet_screen.dart';
import '../pets/my_pets_screen.dart';
import '../adoption_requests/request_list_screen.dart';

class RefugioMenu extends StatelessWidget {
  const RefugioMenu({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel del Refugio 🏠'),
        backgroundColor: AppColors.coralSuave,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedButton(
              icon: Icons.add_circle_outline,
              label: 'Añadir Mascota',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddPetScreen()),
              ),
            ),
            const SizedBox(height: 16),
            AnimatedButton(
              icon: Icons.list_alt,
              label: 'Mis Mascotas',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyPetsScreen()),
              ),
            ),
            const SizedBox(height: 16),
            AnimatedButton(
              icon: Icons.mail_outline,
              label: 'Solicitudes Recibidas',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RequestListScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const AnimatedButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.melocotonPastel.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Row(
          children: [
            Icon(icon, size: 32, color: AppColors.coralSuave),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.marronClaro,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
