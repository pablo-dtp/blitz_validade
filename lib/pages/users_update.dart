import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Para obter o token

class UpdateUser extends StatefulWidget {
  final String currentUsername;  // Alterado para usar username
  final String currentName;
  final int currentPermissionLevel;
  final Function refreshUsers;

  const UpdateUser({
    super.key,
    required this.currentUsername,  // Alterado para usar username
    required this.currentName,
    required this.currentPermissionLevel,
    required this.refreshUsers,
  });

  @override
  _UpdateUserState createState() => _UpdateUserState();
}

class _UpdateUserState extends State<UpdateUser> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  int _selectedPermissionLevel = 1;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _usernameController = TextEditingController(text: widget.currentUsername);  // Alterado para username
    _selectedPermissionLevel = widget.currentPermissionLevel;
  }

Future<void> _updateUser() async {
  if (_nameController.text.trim().isEmpty || _usernameController.text.trim().isEmpty) {
    setState(() {
      _errorMessage = 'Nome e Username não podem estar vazios.';
    });
    return;
  }

  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  // Obter o token de autenticação
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token'); // Ou onde o token for armazenado

  if (token == null) {
    setState(() {
      _errorMessage = 'Token não encontrado. Faça login novamente.';
      _isLoading = false;
    });
    return;
  }

  final url = Uri.parse('${dotenv.env['API_BASE_URL']}/update_user/${widget.currentUsername}'); // Alterado para usar username
  final response = await http.put(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Adicionando o token ao cabeçalho
    },
    body: json.encode({
      'name': _nameController.text.trim(),
      'username': _usernameController.text.trim(),
      'permission_level': _selectedPermissionLevel,
    }),
  );

  setState(() {
    _isLoading = false;
  });

  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuário atualizado com sucesso')),
    );
    widget.refreshUsers();
    Navigator.pop(context);
  } else if (response.statusCode == 403) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Você não pode alterar seu próprio perfil.')),
    );
    Navigator.pop(context); // Fecha a tela e volta para a anterior em caso de erro 403
  } else if (response.statusCode == 401) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Token inválido ou expirado. Faça login novamente.')),
    );
  } else if (response.statusCode == 400) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nome de usuário já existente, tente outro.')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Erro ao atualizar usuário. Tente novamente mais tarde.')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Usuário'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'Username'),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]'))],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nome Completo'),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z ]'))],
          ),
          const SizedBox(height: 10),
          DropdownButton<int>(
            value: _selectedPermissionLevel,
            onChanged: (newValue) {
              setState(() {
                _selectedPermissionLevel = newValue!;
              });
            },
            items: const [
              DropdownMenuItem(value: 1, child: Text('Repositor')),
              DropdownMenuItem(value: 2, child: Text('Gerente')),
              DropdownMenuItem(value: 3, child: Text('Admin')),
            ],
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateUser,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Salvar'),
        ),
      ],
    );
  }
}
