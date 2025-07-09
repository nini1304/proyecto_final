import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'config/theme.dart';
import 'presentation/auth/login_screen.dart';
import 'presentation/pets/pet_list_screen.dart';
import 'presentation/adoption_requests/request_list_screen.dart';
import 'presentation/pets/add_pet_screen.dart';
import 'presentation/menus/adoptante_menu.dart';
import 'presentation/menus/refugio_menu.dart';

class PetAdoptApp extends ConsumerStatefulWidget {
  const PetAdoptApp({super.key});

  @override
  ConsumerState<PetAdoptApp> createState() => _PetAdoptAppState();
}

class _PetAdoptAppState extends ConsumerState<PetAdoptApp> {
  Future<String?> getUserRole(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.exists ? doc['role'] as String : null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PetAdopt',
      theme: appTheme,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (!snapshot.hasData) return const LoginScreen();

          final user = snapshot.data!;

          return FutureBuilder<String?>(
            future: getUserRole(user.uid),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final role = snapshot.data;

              if (role == 'refugio') {
                return const RefugioMenu();
              } else {
                return const AdoptanteMenu();
              }
            },
          );
        },
      ),
    );
  }
}