import 'imports.dart';

class ManageProductsPage extends StatelessWidget {
  const ManageProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildManageProductsPage();
  }

  Widget _buildManageProductsPage() {
    return Container(
      decoration: const BoxDecoration(color: AppColors.primaryColor),
      child: Column(
        children: [
          AppBar(
            backgroundColor: AppColors.primaryColor,
            title: Center(
              child: Image.asset('assets/logo.png', width: 80, height: 80),
              ),
            ),
          ],
        ),
      );
  }
}