import 'package:flutter/material.dart';
import '../../controllers/client_controller.dart';
import '../../models/client.dart';
import 'client_form_screen.dart';

class ClientListScreen extends StatefulWidget {
  @override
  _ClientListScreenState createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  @override
  void initState() {
    super.initState();
    ClientController().loadClients().then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Clientes')),
      body: ListView.builder(
        itemCount: ClientController().clients.length,
        itemBuilder: (context, index) {
          final client = ClientController().clients[index];
          return ListTile(
            title: Text(client.nome),
            subtitle: Text(client.tipo == 'F' ? 'Pessoa Física' : 'Pessoa Jurídica'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: Icon(Icons.edit), onPressed: () => _editClient(context, client)),
                IconButton(icon: Icon(Icons.delete), onPressed: () => _deleteClient(client.id)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(child: Icon(Icons.add), onPressed: () => _addClient(context)),
    );
  }

  void _addClient(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ClientFormScreen())).then((_) => setState(() {}));
  }

  void _editClient(BuildContext context, Client client) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ClientFormScreen(client: client)),
    ).then((_) => setState(() {}));
  }

  void _deleteClient(String id) {
    ClientController().deleteClient(id);
    setState(() {});
  }
}
