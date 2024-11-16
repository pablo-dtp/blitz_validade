// ignore_for_file: file_names

import 'imports.dart';
import 'package:http/http.dart' as http;

class UpdateUser extends StatefulWidget {
  final int userId;
  final String currentName;
  final int currentPermissionLevel;
  final Function refreshUsers;

  const UpdateUser({
    super.key,
    required this.userId,
    required this.currentName,
    required this.currentPermissionLevel,
    required this.refreshUsers,
  });

  @override
  _UpdateUserState createState() => _UpdateUserState();
}

class _UpdateUserState extends State<UpdateUser> {
  late TextEditingController _nameController;
  int _selectedPermissionLevel = 1;
  bool _isLoading = false; // Indicador de carregamento
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _selectedPermissionLevel = widget.currentPermissionLevel;
  }

  Future<void> _updateUser() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'O nome não pode estar vazio.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final url = Uri.parse('${dotenv.env['API_BASE_URL']}/update_user/${widget.userId}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': _nameController.text.trim(),
        'permission_level': _selectedPermissionLevel,
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      // Mostra mensagem de sucesso e atualiza a lista de usuários
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuário atualizado com sucesso')),
      );
      widget.refreshUsers();
      Navigator.pop(context); // Fecha o diálogo somente após sucesso
    } else {
      setState(() {
        _errorMessage = 'Erro ao atualizar usuário: ${response.body}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage!)),
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
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nome Completo'),
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
          onPressed: _isLoading ? null : _updateUser, // Desabilita botão durante carregamento
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
