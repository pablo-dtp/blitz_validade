import 'package:http/http.dart' as http;
import 'imports.dart';

class DeleteUser extends StatelessWidget {
  final int userId;
  final Function refreshUsers;

  const DeleteUser({super.key, required this.userId, required this.refreshUsers});

  Future<void> _deleteUser(BuildContext context) async {
    final url = Uri.parse('${dotenv.env['API_BASE_URL']}/delete_user/$userId');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Usuário deletado com sucesso')));

      refreshUsers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao deletar usuário')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete, color: Colors.black),
      onPressed: () {
        _deleteUser(context);
      },
    );
  }
}
