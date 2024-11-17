import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Para obter o token

class DeleteUser extends StatelessWidget {
  final String username;  // Alterado para usar o username
  final Function refreshUsers;

  const DeleteUser({super.key, required this.username, required this.refreshUsers});

  // Tornando a função pública, sem o prefixo "_"
  Future<void> deleteUser(BuildContext context) async {
    // Obter o token de autenticação
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token'); // Ou onde o token for armazenado

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token não encontrado. Faça login novamente.')),
      );
      return;
    }

    final url = Uri.parse('${dotenv.env['API_BASE_URL']}/delete_user/$username');  // Alterado para usar username
    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token', // Adicionando o token ao cabeçalho
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário deletado com sucesso!')),
        );
        refreshUsers(); // Chama a função para atualizar a lista de usuários
      } else if (response.statusCode == 403) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Você não pode deletar seu próprio perfil.')),
        );
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Token inválido ou expirado. Faça login novamente.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao deletar usuário. Tente novamente mais tarde.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao fazer requisição: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete, color: Colors.black),
      onPressed: () {
        deleteUser(context); // Chama a função pública de deletação
      },
    );
  }
}
