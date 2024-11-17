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
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    // Distância de 10% da altura da tela para o botão
    double containerHeight = screenHeight * 0.4; // Container ocupa 40% da tela
    double containerTopMargin = screenHeight * 0.15; // Ajusta para ficar mais centralizado

    // Espaçamento fixo de 5px entre os campos
    double fieldHeight = 60.0;  // Altura fixa para os campos

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
            Positioned(
              top: 10,
              left: screenWidth * 0.5 - 40, // Ajuste o valor para centralizar a logo
              child: Image.asset(
                'assets/logo.png',
                width: 80,
                height: 80,
              ),
            ),
          ],
        ),
      ),
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          // Bloqueia o movimento vertical
          return;
        },
        onHorizontalDragUpdate: (details) {
          // Bloqueia o movimento horizontal
          return;
        },
        child: Container(
          height: screenHeight,
          decoration: BoxDecoration(color: AppColors.primaryColor),
          child: Stack(
            children: [
              Positioned(
                top: containerTopMargin,
                left: screenWidth * 0.1, // 10% da largura
                right: screenWidth * 0.1, // 10% da largura
                child: Container(
                  height: containerHeight,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.auxiliaryColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10.0,
                        offset: Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildTextField(usernameController, 'Usuário', isUserField: true, fieldHeight: fieldHeight),
                      const SizedBox(height: 5), // Espaço fixo entre os campos
                      _buildTextField(passwordController, 'Senha', obscureText: true, fieldHeight: fieldHeight),
                      const SizedBox(height: 5),
                      _buildTextField(nameController, 'Nome completo', fieldHeight: fieldHeight),
                      const SizedBox(height: 5),
                      _buildPermissionLevelDropdown(fieldHeight),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: containerTopMargin + containerHeight + 30, // Espaço fixo de 5px entre o container e o botão
                left: screenWidth * 0.15,
                right: screenWidth * 0.15,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    foregroundColor: const Color.fromARGB(255, 255, 0, 0),
                    shadowColor: (const Color.fromARGB(255, 0, 0, 0)),
                    elevation: 10,
                  ),
                  onPressed: isButtonEnabled ? _addUser : null,
                  child: const Text("Adicionar Usuário"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool obscureText = false, bool isUserField = false, double? fieldHeight}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        height: fieldHeight ?? 60.0, // Usar o valor calculado ou padrão
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
      ),
    );
  }

  Widget _buildPermissionLevelDropdown(double? fieldHeight) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: SizedBox(
          height: fieldHeight ?? 60.0, // Usar o valor calculado ou padrão
          child: DropdownButtonFormField<int>(
            value: selectedPermissionLevel,
            decoration: InputDecoration(
              labelText: 'Função',
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
            hint: const Text('Selecione a função'),
          ),
        ),
      );
    }
}
