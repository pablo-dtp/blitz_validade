import 'imports.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool rememberMe = false;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool isButtonEnabled = false;
  bool isPasswordVisible = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    usernameController.addListener(_checkForm);
    passwordController.addListener(_checkForm);
    _checkSavedCredentials();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _checkForm() {
    setState(() {
      isButtonEnabled = usernameController.text.isNotEmpty && passwordController.text.isNotEmpty;
    });
  }

  Future<void> _login() async {
    final response = await http.post(
      Uri.parse('http://192.168.1.2:5000/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': usernameController.text.toLowerCase(),
        'password': passwordController.text.toLowerCase(),
      }),
    );

    if (response.statusCode == 200) {
      if (mounted) {
        final responseBody = json.decode(response.body);
        final permissionLevel = responseBody['permission_level'];

        // Armazenar dados com SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt('permission_level', permissionLevel);

        // Armazenar as credenciais e o estado do "Continuar Conectado"
        if (rememberMe) {
          prefs.setString('username', usernameController.text);
          prefs.setString('password', passwordController.text);
          prefs.setBool('remember_me', rememberMe);  // Salvar o estado do checkbox
        } else {
          prefs.remove('username');
          prefs.remove('password');
        }

        // Navegar para a HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } else {
      // Se o login falhar, apaga as credenciais salvas
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('username');
      prefs.remove('password');
      prefs.remove('remember_me');

      if (mounted) {
        setState(() {
          errorMessage = json.decode(response.body)['message'];
        });
      }
    }
  }

  // Verificar se há credenciais e o estado do "Continuar conectado" salvos
  Future<void> _checkSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString('username');
    String? savedPassword = prefs.getString('password');
    bool? savedRememberMe = prefs.getBool('remember_me');

    if (savedUsername != null && savedPassword != null) {
      // Preencher os campos com as credenciais salvas
      usernameController.text = savedUsername;
      passwordController.text = savedPassword;

      // Restaurar o estado do "Continuar conectado"
      setState(() {
        rememberMe = savedRememberMe ?? false;  // Caso não exista, assume como false
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(color: AppColors.primaryColor),
          child: Stack(
            children: [
              _buildLogo(),
              _buildLoginContainer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Positioned(
      top: 40,
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

  Widget _buildLoginContainer() {
    return Positioned(
      top: 420,
      left: 20,
      right: 20,
      child: Container(
        height: 380,
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
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            _buildTextField(usernameController, 'Usuário'),
            const SizedBox(height: 20),
            _buildPasswordField(),
            const SizedBox(height: 10),
            _buildRememberMeCheckbox(),
            const SizedBox(height: 10),
            _buildLoginButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          labelStyle: TextStyle(color: AppColors.secondaryColor),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')), // Permite apenas letras
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        controller: passwordController,
        obscureText: !isPasswordVisible,
        decoration: InputDecoration(
          labelText: 'Senha',
          border: OutlineInputBorder(),
          labelStyle: TextStyle(color: AppColors.secondaryColor),
          suffixIcon: IconButton(
            icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                isPasswordVisible = !isPasswordVisible;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRememberMeCheckbox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Garante alinhamento central
        children: [
          Checkbox(
            value: rememberMe,
            onChanged: (value) async {
              setState(() {
                rememberMe = value!;
              });

              // Armazenar o estado do "Continuar conectado"
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool('remember_me', rememberMe);

              if (!rememberMe) {
                // Remover credenciais se a opção for desmarcada
                prefs.remove('username');
                prefs.remove('password');
              }
            },
            checkColor: AppColors.auxiliaryColor,
            activeColor: AppColors.effectColor,
          ),
          SizedBox(width: 0), // Ajusta o espaçamento entre o checkbox e o texto
          const Text(
            'Continuar conectado',
            //style: TextStyle(fontSize: 16), // Ajusta o tamanho da fonte, se necessário
          ),
        ],
      ),
    );
  }



  Widget _buildLoginButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SizedBox(
        width: double.infinity, // Ocupa toda a largura disponível
        child: ElevatedButton.icon(
          onPressed: isButtonEnabled ? _login : null,
          icon: const Icon(Icons.login, color: AppColors.auxiliaryColor),
          label: const Text(
            'Entrar',
            style: TextStyle(
              color: AppColors.auxiliaryColor,
              overflow: TextOverflow.ellipsis, // Previne que o texto quebre
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: isButtonEnabled ? AppColors.effectColor : const Color(0xFFB8B4B4),
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }
}
