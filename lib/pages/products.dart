// ignore_for_file: file_names

import 'imports.dart';

class ManageProductsPage extends StatelessWidget {
  const ManageProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildManageProductsPage();
  }

  Widget _buildManageProductsPage() {
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