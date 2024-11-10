import 'package:flutter/material.dart';
import 'usersView.dart';
import 'imports.dart'; // Importando o arquivo que contém a tabela

class ManagePeoplePage extends StatelessWidget {
  const ManagePeoplePage({super.key});

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: 20),
          const UserTable(), // Aqui usamos o widget da tabela
          const SizedBox(height: 20), // Espaçamento entre a tabela e o botão
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.auxiliaryColor, // Cor de fundo do botão
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30), // Padding do botão
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)), // Borda sem arredondamento
              foregroundColor: AppColors.primaryColor, // Cor do texto do botão
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddUserPage()),
              );
            },
            child: const Text("Adicionar Novo Usuário"),
          ),
        ],
      ),
    );
  }
}
