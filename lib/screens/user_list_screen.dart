import 'package:flutter/material.dart';
import '../../controllers/user_controller.dart';
import '../../models/user.dart';
import 'user_form_screen.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  void initState() {
    super.initState();
    UserController().loadUsers().then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Usuários')),
      body: ListView.builder(
        itemCount: UserController().users.length,
        itemBuilder: (context, index) {
          final user = UserController().users[index];
          return ListTile(
            title: Text(user.nome),
            subtitle: Text(user.id),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: Icon(Icons.edit), onPressed: () => _editUser(context, user)),
                IconButton(icon: Icon(Icons.delete), onPressed: () => _deleteUser(user.id)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(child: Icon(Icons.add), onPressed: () => _addUser(context)),
    );
  }

  void _addUser(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => UserFormScreen())).then((_) => setState(() {}));
  }

  void _editUser(BuildContext context, User user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserFormScreen(user: user)),
    ).then((_) => setState(() {}));
  }

  void _deleteUser(String id) {
    UserController().deleteUser(id);
    setState(() {});
  }
}
