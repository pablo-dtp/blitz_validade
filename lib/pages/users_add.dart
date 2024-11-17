import 'package:shared_preferences/shared_preferences.dart';

import 'imports.dart';
import 'package:http/http.dart' as http;

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  int? selectedPermissionLevel;

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
      isButtonEnabled = usernameController.text.isNotEmpty &&
          passwordController.text.isNotEmpty &&
          nameController.text.isNotEmpty &&
          selectedPermissionLevel != null;
    });
  }

  String formatName(String name) {
    List<String> prepositions = ['de', 'da', 'do', 'das', 'dos', 'e', 'a', 'o', 'as', 'os', 'para', 'com'];
    return name
        .split(' ')
        .map((word) {
          if (prepositions.contains(word.toLowerCase())) {
            return word.toLowerCase();
          } else {
            return word.isNotEmpty
                ? word[0].toUpperCase() + word.substring(1).toLowerCase()
                : '';
          }
        }).join(' ');
  }

  Future<void> _addUser() async {
    // Obter o token de autenticação
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token'); // Token armazenado no SharedPreferences

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token não encontrado. Faça login novamente.')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('${dotenv.env['API_BASE_URL']}/add_user'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',  // Adicionando o token no cabeçalho
      },
      body: json.encode({
        'username': usernameController.text.toLowerCase(),
        'password': passwordController.text.toLowerCase(),
        'name': formatName(nameController.text),
        'permission_level': selectedPermissionLevel,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      final String message = responseBody['message'];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

      // Limpar os campos após sucesso
      usernameController.clear();
      passwordController.clear();
      nameController.clear();
      setState(() {
        selectedPermissionLevel = null;
      });

      Navigator.pop(context, true);
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
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: CircleAvatar(
              backgroundColor: AppColors.auxiliaryColor,
              child: Icon(
                Icons.arrow_back,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ),
        flexibleSpace: Stack(
          children: [
            // Logo com 10px de distância do topo
            Positioned(
              top: 10,
              left: MediaQuery.of(context).size.width * 0.5 - 40, // Ajuste o valor para centralizar a logo
              child: Image.asset(
                'assets/logo.png',
                width: 80,
                height: 80,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(color: AppColors.primaryColor),
          child: Stack(
            children: [
              _buildAddUserForm(),
            ],
          ),
        ),
      ),
    );
  }

Widget _buildAddUserForm() {
  double screenHeight = MediaQuery.of(context).size.height;
  double screenWidth = MediaQuery.of(context).size.width;

  return Positioned(
    top: screenHeight * 0.2,  // 25% de distância da AppBar
    left: screenWidth * 0.1,  // 10% de distância da esquerda
    right: screenWidth * 0.1,  // 10% de distância da direita
    child: Container(
      height: screenHeight * 0.415,  // 40% da altura da tela
      padding: const EdgeInsets.all(16.0),
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
        children: [
          _buildTextField(usernameController, 'Usuário', isUserField: true),
          const SizedBox(height: 0),
          _buildTextField(passwordController, 'Senha', obscureText: true),
          const SizedBox(height: 0),
          _buildTextField(nameController, 'Nome completo'),
          const SizedBox(height: 0),
          _buildPermissionLevelDropdown(),
          const SizedBox(height: 0),
          ElevatedButton(
            onPressed: isButtonEnabled ? _addUser : null,
            child: const Text("Adicionar Usuário"),
          ),
        ],
      ),
    ),
  );
}

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
            ? [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]'))]
            : label == 'Senha'
                ? []
                : [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z ]'))],
      ),
    );
  }

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
            _checkForm();
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
