import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class UsersTab extends StatefulWidget {
  const UsersTab({super.key});

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  final FirestoreService firestoreService = FirestoreService();

  List<Map<String, dynamic>> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    setState(() => isLoading = true);

    try {
      users = await firestoreService.fetchUsersOnce();
      if (kDebugMode) {
        print(users);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    print(users.length); //

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];

        return ListTile(
          leading: const Icon(Icons.person),
          title: Text(user['name'] ?? ''),
          subtitle: Text(user['email'] ?? ''),
        );
      },
    );
  }
}
