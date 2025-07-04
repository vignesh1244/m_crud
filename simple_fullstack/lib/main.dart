import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'user_model.dart';

void main() => runApp(UserApp());

class UserApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: UserScreen());
  }
}

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  // final String apiUrl = "http://10.0.2.2:5000/api/users";
  final String apiUrl = "http://localhost:5000/api/users";
  // http://localhost:5000/api/users

  List<User> users = [];
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  String? editingId;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      setState(() {
        users = data.map((u) => User.fromJson(u)).toList();
      });
    }
  }

  Future<void> submitUser() async {
    final user = {'name': nameController.text, 'email': emailController.text};

    if (editingId != null) {
      await http.put(
        Uri.parse('$apiUrl/$editingId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(user),
      );
    } else {
      await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(user),
      );
    }

    nameController.clear();
    emailController.clear();
    editingId = null;
    fetchUsers();
  }

  Future<void> deleteUser(String id) async {
    await http.delete(Uri.parse('$apiUrl/$id'));
    fetchUsers();
  }

  void startEdit(User user) {
    nameController.text = user.name;
    emailController.text = user.email;
    setState(() {
      editingId = user.id;
    });
  }

  Future<void> fetchUsersa() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        print("Success: ${response.body}");
        final List data = json.decode(response.body);
        setState(() {
          users = data.map((u) => User.fromJson(u)).toList();
        });
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Management')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),

            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 10),

            ElevatedButton(
              onPressed: submitUser,
              child: Text(editingId != null ? 'Update User' : 'Add User'),
            ),
            SizedBox(height: 20),
            // User List
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (_, index) {
                  final user = users[index];

                  return Card(
                    child: ListTile(
                      title: Text(user.name),
                      subtitle: Text(user.email),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => startEdit(user),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => deleteUser(user.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
