import 'imports.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Widget> _pages = [
    AddProductPage(),
    ManageProductsPage(),
    ManagePeoplePage(),
    SettingsPage(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onItemTapped(int index) async {
    // Verifica se o usuário tem permissão para acessar a página de "Usuários"
    if (index == 2) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int permissionLevel = prefs.getInt('permission_level') ?? 0;
      if (permissionLevel < 3) {
        _showPermissionAlert();
        return;
      }
    }

    setState(() {
      _currentIndex = index;
    });

    // Navegar para a página desejada
    _pageController.jumpToPage(index);
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
                Navigator.of(context).pop();
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
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: AppColors.auxiliaryColor),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.add_shopping_cart), label: 'Registrar'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Visualizar'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Usuários'),
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
