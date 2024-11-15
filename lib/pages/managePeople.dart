import 'addUsersPage.dart';
import 'usersView.dart';
import 'package:http/http.dart' as http;
import 'imports.dart'; // Importando o arquivo que contém a tabela

class ManagePeoplePage extends StatefulWidget {
  const ManagePeoplePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ManagePeoplePageState createState() => _ManagePeoplePageState();
}

class _ManagePeoplePageState extends State<ManagePeoplePage> {
  bool isLoading = false; // Indicador de carregamento

  @override
  void initState() {
    super.initState();
    _loadUsers(); // Carregar os usuários ao iniciar a página
  }

  // Método para carregar os usuários
  Future<void> _loadUsers() async {
    setState(() {
      isLoading = true; // Indicando que a atualização está em andamento
    });

    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:5000/get_users'));
      if (response.statusCode == 200) {
        setState(() {
          isLoading = false; // Atualização completada
        });
      } else {
        setState(() {
          isLoading = false; // Atualização falhou
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar os usuários')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar os usuários: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: const [AppColors.primaryColor, AppColors.auxiliaryColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.1, 0.6],
          ),
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: AppColors.primaryColor,
              title: Center(
                child: Image.asset('assets/logo.png', width: 80, height: 80),
              ),
            ),
            const SizedBox(height: 20),
            // Tabela de usuários ou indicador de carregamento
            isLoading
                ? const CircularProgressIndicator() // Mostrar o loading
                : const UserTable(), // Tabela de usuários

            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.auxiliaryColor,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                foregroundColor: AppColors.primaryColor,
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddUserPage()),
                );

                // Após retornar da tela de adicionar usuário, recarregar a lista
                if (result == true) {
                  _loadUsers(); // Recarregar a lista de usuários
                }
              },
              child: const Text("Adicionar Novo Usuário"),
            ),
          ],
        ),
      ),
    );
  }
}
