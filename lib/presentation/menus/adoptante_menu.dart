import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../config/palette.dart';
import '../pets/pet_list_screen.dart';
import '../adoption_requests/request_list_screen.dart';

class AdoptanteMenu extends StatefulWidget {
  const AdoptanteMenu({super.key});

  @override
  State<AdoptanteMenu> createState() => _AdoptanteMenuState();
}

class _AdoptanteMenuState extends State<AdoptanteMenu> {
  int _index = 0;
  final _screens = [
    const PetListScreen(),
    const RequestListScreen(),
  ];

  void _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.coralSuave,
        title: const Text('PetAdopt 🐾'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: _screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.melocotonPastel,
        selectedItemColor: AppColors.coralSuave,
        unselectedItemColor: AppColors.marronClaro,
        currentIndex: _index,
        onTap: (value) => setState(() => _index = value),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Mascotas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Solicitudes',
          ),
        ],
      ),
    );
  }
}
