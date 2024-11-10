import 'imports.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';// Importando para usar o TextInputFormatter

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  int? selectedPermissionLevel;  // Armazenar o nível de permissão selecionado

  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    usernameController.addListener(_checkForm);
    passwordController.addListener(_checkForm);
    nameController.addListener(_checkForm);
  }

  void _checkForm() {
    setState(() {
      // O botão será habilitado quando todos os campos estiverem preenchidos e o permission_level estiver selecionado
      isButtonEnabled = usernameController.text.isNotEmpty &&
          passwordController.text.isNotEmpty &&
          nameController.text.isNotEmpty &&
          selectedPermissionLevel != null;
    });
  }

  // Função para formatar o nome (primeira letra de cada palavra em maiúscula, exceto preposições)
  String formatName(String name) {
    List<String> prepositions = ['de', 'da', 'do', 'das', 'dos', 'e', 'a', 'o', 'as', 'os', 'para', 'com'];
    return name
        .split(' ') // Divide o nome em palavras
        .map((word) {
          if (prepositions.contains(word.toLowerCase())) {
            return word.toLowerCase(); // Mantém as preposições em minúsculas
          } else {
            return word.isNotEmpty
                ? word[0].toUpperCase() + word.substring(1).toLowerCase() // Primeira letra em maiúscula e o restante em minúscula
                : ''; // Caso a palavra esteja vazia
          }
        }).join(' '); // Junta as palavras de volta com espaço
  }

  // Função para enviar o novo usuário para o servidor
  Future<void> _addUser() async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/add_user'),
      headers: {
        'Content-Type': 'application/json',
        'Username': 'admin_role',  // Substitua com o username correto
        'Password': 'root',  // Substitua com a senha correta
      },
      body: json.encode({
        'username': usernameController.text.toLowerCase(), // Convertendo username para minúsculas
        'password': passwordController.text.toLowerCase(), // Convertendo password para minúsculas
        'name': formatName(nameController.text), // Formatando nome
        'permission_level': selectedPermissionLevel,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      final int newUserId = responseBody['user_id'];

      // Exibe um snackbar de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuário adicionado com sucesso! ID: $newUserId')),
      );

      // Limpa os campos
      usernameController.clear();
      passwordController.clear();
      nameController.clear();
      setState(() {
        selectedPermissionLevel = null;  // Limpa a seleção do permission level
      });
    } else {
      final responseBody = json.decode(response.body);
      final String errorMessage = responseBody['message'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $errorMessage')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(color: AppColors.primaryColor), // Alterando fundo para a cor primária
          child: Stack(
            children: [
              _buildBackButton(), // Botão de voltar adicionado aqui
              _buildLogo(),
              _buildAddUserForm(),
            ],
          ),
        ),
      ),
    );
  }

  // Função para construir o botão de voltar
  Widget _buildBackButton() {
    return Positioned(
      top: 40, // Ajuste a posição do botão de volta
      left: 20, // Colocando o botão do lado esquerdo
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context); // Retorna para a página anterior
        },
        child: Container(
          padding: const EdgeInsets.all(8.0), // Tamanho do círculo
          decoration: BoxDecoration(
            color: Colors.white, // Cor de fundo do círculo
            shape: BoxShape.circle, // Forma circular
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back, // Ícone da seta para a esquerda
            color: AppColors.primaryColor, // Cor da seta (usando a cor do fundo)
            size: 24, // Tamanho do ícone
          ),
        ),
      ),
    );
  }

  // Função para construir a logo
  Widget _buildLogo() {
    return Positioned(
      top: 100, // Ajusta a posição da logo para que o botão de voltar não a cubra
      left: 0,
      right: 0,
      child: Center(
        child: Image.asset(
          'assets/logo.png',
          width: MediaQuery.of(context).size.width * 0.6,
          height: MediaQuery.of(context).size.width * 0.6 * (380 / 380),
        ),
      ),
    );
  }

  // Função para construir o formulário de adição de usuário
  Widget _buildAddUserForm() {
    return Positioned(
      bottom: 20, // Coloca o formulário na parte inferior
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(25.0),
        decoration: BoxDecoration(
          color: AppColors.auxiliaryColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTextField(usernameController, 'Usuario', isUserField: true),
            const SizedBox(height: 20),
            _buildTextField(passwordController, 'Senha', obscureText: true),
            const SizedBox(height: 20),
            _buildTextField(nameController, 'Nome completo'),
            const SizedBox(height: 20),
            _buildPermissionLevelDropdown(),  // Adicionando o Dropdown para o permission_level
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isButtonEnabled ? _addUser : null,
              child: const Text("Adicionar Usuário"),
            ),
          ],
        ),
      ),
    );
  }

  // Função para construir um campo de texto
  Widget _buildTextField(TextEditingController controller, String label, {bool obscureText = false, bool isUserField = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        inputFormatters: isUserField 
            ? [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]'))] // Permite apenas letras, números e underscore para o usuário
            : label == 'Senha'
                ? [] // Sem restrição para a senha
                : [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z ]'))], // Permite apenas letras e espaços para o nome
      ),
    );
  }

  // Função para construir o dropdown de seleção do permission level
  Widget _buildPermissionLevelDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<int>(
        value: selectedPermissionLevel,
        decoration: InputDecoration(
          labelText: 'Nível de permissão',
          border: const OutlineInputBorder(),
        ),
        onChanged: (int? newValue) {
          setState(() {
            selectedPermissionLevel = newValue;
            _checkForm(); // Garantir que a verificação seja feita ao alterar o nível de permissão
          });
        },
        items: const [
          DropdownMenuItem(value: 1, child: Text('Repositor')),
          DropdownMenuItem(value: 2, child: Text('Gerente')),
          DropdownMenuItem(value: 3, child: Text('Admin')),
        ],
        hint: const Text('Selecione o nível de permissão'),
      ),
    );
  }
}
