import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class SelectUserPage extends StatefulWidget {
  const SelectUserPage({super.key});

  @override
  State<SelectUserPage> createState() => _SelectUserPageState();
}

class _SelectUserPageState extends State<SelectUserPage> {
  final FirestoreService firestoreService = FirestoreService();

  List<Map<String, dynamic>> users = [];
  Map<String, dynamic>? selectedUser;
  bool isLoading = true;
  bool isBooking = false;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
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

  Future<void> createBooking() async {
    if (selectedUser == null) return;

    setState(() => isBooking = true);

    try {
      await firestoreService.createBooking(
        targetUserId: selectedUser!['uid'],
        targetUserName: selectedUser!['name'],
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
      setState(() => isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select User')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: users.isEmpty
                      ? const Center(child: Text('No users available'))
                      : ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            final isSelected =
                                selectedUser?['uid'] == user['uid'];

                            return ListTile(
                              leading: Icon(
                                isSelected
                                    ? Icons.check_circle
                                    : Icons.person_outline,
                              ),
                              title: Text(user['name'] ?? ''),
                              subtitle: Text(user['email'] ?? ''),
                              onTap: () {
                                setState(() {
                                  selectedUser = user;
                                });
                              },
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedUser == null || isBooking
                          ? null
                          : createBooking,
                      child: isBooking
                          ? const CircularProgressIndicator()
                          : const Text('Book'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
