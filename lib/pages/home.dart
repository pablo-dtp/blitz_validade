import 'imports.dart';

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

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
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
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Gerenciar Usuarios'),
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
