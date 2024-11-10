import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UpdateUser extends StatefulWidget {
  final int userId;
  final String currentName;
  final int currentPermissionLevel;
  final Function refreshUsers;  // Função para recarregar os usuários

  const UpdateUser({
    super.key,
    required this.userId,
    required this.currentName,
    required this.currentPermissionLevel,
    required this.refreshUsers,  // Recebe a função de recarregar usuários
  });

  @override
  _UpdateUserState createState() => _UpdateUserState();
}

class _UpdateUserState extends State<UpdateUser> {
  late TextEditingController _nameController;
  int _selectedPermissionLevel = 1;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _selectedPermissionLevel = widget.currentPermissionLevel;
  }

  Future<void> _updateUser() async {
    final url = Uri.parse('http://10.0.2.2:5000/update_user/${widget.userId}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': _nameController.text,
        'permission_level': _selectedPermissionLevel,
      }),
    );

    if (response.statusCode == 200) {
      // Exibe um Snackbar de sucesso
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Usuário atualizado')));
      
      // Chama a função de recarregar os usuários
      widget.refreshUsers();  // Recarrega a lista de usuários após a atualização
    } else {
      // Exibe um Snackbar de erro
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao atualizar usuário')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Editar Usuário'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Nome Completo'),
          ),
          DropdownButton<int>(
            value: _selectedPermissionLevel,
            onChanged: (newValue) {
              setState(() {
                _selectedPermissionLevel = newValue!;
              });
            },
            items: [
              DropdownMenuItem(value: 1, child: Text('Repositor')),
              DropdownMenuItem(value: 2, child: Text('Gerente')),
              DropdownMenuItem(value: 3, child: Text('Admin')),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            _updateUser();
            Navigator.pop(context);
          },
          child: Text('Salvar'),
        ),
      ],
    );
  }
}
