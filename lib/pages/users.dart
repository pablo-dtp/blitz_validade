import 'users_add.dart';
import 'users_view.dart';
import 'package:http/http.dart' as http;
import 'imports.dart';

class ManagePeoplePage extends StatefulWidget {
  const ManagePeoplePage({super.key});

  @override
  _ManagePeoplePageState createState() => _ManagePeoplePageState();
}

class _ManagePeoplePageState extends State<ManagePeoplePage> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('${dotenv.env['API_BASE_URL']}/get_users'));
      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              AppBar(
                backgroundColor: AppColors.primaryColor,
                title: Center(
                  child: Image.asset('assets/logo.png', width: 80, height: 80),
                ),
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : const UserTable(),

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

                  if (result == true) {
                    _loadUsers();
                  }
                },
                child: const Text("Adicionar Novo Usuário"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
