import 'imports.dart';

class ManagePeoplePage extends StatelessWidget {
  const ManagePeoplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildManagePeoplePage();
  }

  Widget _buildManagePeoplePage() {
    return Container(
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
          ],
        ), // Customize here
      );
  }
}