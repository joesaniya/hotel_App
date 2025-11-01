import 'package:flutter/material.dart';
import 'package:hotel_app/business_logic/auth-provider.dart';
import 'package:provider/provider.dart';

import 'sign_in_screen.dart';

class HomeScreen extends StatelessWidget {
  final dynamic user;
  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome ${user.displayName ?? ''}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SignInScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (user.photoURL != null)
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(user.photoURL!),
              ),
            const SizedBox(height: 16),
            Text(user.displayName ?? ''),
            Text(user.email ?? ''),
          ],
        ),
      ),
    );
  }
}
