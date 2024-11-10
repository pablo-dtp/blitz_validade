import 'imports.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildSettingsPage(context);
  }

  Widget _buildSettingsPage(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: const [AppColors.primaryColor, AppColors.auxiliaryColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.13, 0],
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
          Expanded(child: Container()), // Expande para ocupar espaço e empurrar o botão para baixo
          _buildLogoutButton(context), // Adiciona o botão "SAIR"
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton.icon(
        onPressed: () {
          // Aqui você pode adicionar a lógica para desconectar o usuário
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        },
        icon: Icon(Icons.logout, color: AppColors.primaryColor), // Define a cor do ícone
        label: Text(
          'SAIR',
          style: TextStyle(color: AppColors.primaryColor), // Define a cor do texto
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.auxiliaryColor,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        ),
      ),
    );
  }
}