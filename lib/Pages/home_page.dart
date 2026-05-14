import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'users_tab.dart';
import 'bookings_tab.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Hero(
            tag: 'appLogo',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/logo11.png', width: 40),

                const SizedBox(width: 10),

                const Text('Arab Therapy'),
              ],
            ),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Users'),
              Tab(text: 'Bookings'),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () async {
                await authService.logout();
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: const TabBarView(children: [UsersTab(), BookingsTab()]),
      ),
    );
  }
}
