import 'imports.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _pages = const [
    AddProductPage(),
    ManageProductsPage(),
    ManagePeoplePage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) async {
    if (index == 2) {
      // Verifica permissão antes de acessar a ManagePeoplePage
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int permissionLevel = prefs.getInt('permission_level') ?? 0;
      // Exibe o permission_level no console para debug
      print('Permission Level: $permissionLevel');
      if (permissionLevel < 3) {
        // Exibe alerta se o usuário não tiver permissão
        _showPermissionAlert();
        return;
      }
    }

    // Permite mudar a página normalmente
    setState(() {
      _currentIndex = index;
    });
  }

  void _showPermissionAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Acesso negado"),
          content: const Text("Você não possui permissão para acessar esta página."),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o alerta
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: AppColors.auxiliaryColor),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.add_shopping_cart), label: 'Registrar Validade'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Gerenciar Validades'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Gerenciar Usuários'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configurações'),
          ],
          currentIndex: _currentIndex,
          selectedItemColor: AppColors.primaryColor,
          unselectedItemColor: AppColors.secondaryColor,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
