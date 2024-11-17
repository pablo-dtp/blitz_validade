import 'imports.dart';
import 'package:http/http.dart' as http;
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
      Uri.parse('${dotenv.env['API_BASE_URL']}/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': usernameController.text.toLowerCase(),
        'password': passwordController.text.toLowerCase(),
      }),
    );

    if (response.statusCode == 200) {
      if (mounted) {
        final responseBody = json.decode(response.body);
        final token = responseBody['token'];  // Aqui, estamos esperando um 'token' no retorno
        final permissionLevel = responseBody['permission_level'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', token); // Salvar o token
        prefs.setInt('permission_level', permissionLevel);

        if (rememberMe) {
          prefs.setString('username', usernameController.text);
          prefs.setString('password', passwordController.text);
          prefs.setBool('remember_me', rememberMe);
        } else {
          prefs.remove('username');
          prefs.remove('password');
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } else {
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

  Future<void> _checkSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString('username');
    String? savedPassword = prefs.getString('password');
    bool? savedRememberMe = prefs.getBool('remember_me');

    if (savedUsername != null && savedPassword != null) {
      usernameController.text = savedUsername;
      passwordController.text = savedPassword;

      setState(() {
        rememberMe = savedRememberMe ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double logoHeight = screenHeight * 0.2;  // A altura da logo será 20% da tela
    double distanceFromLogo = logoHeight * 0.15; // Distância fixa do container de login para a logo

    double logoTopPosition = screenHeight * 0.1; // Logo 10% abaixo do topo da tela
    double loginContainerTopPosition = logoTopPosition + logoHeight + distanceFromLogo;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: screenHeight,
          decoration: const BoxDecoration(color: AppColors.primaryColor),
          child: Stack(
            children: [
              _buildLogo(logoTopPosition),
              _buildLoginContainer(loginContainerTopPosition),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(double topPosition) {
    return Positioned(
      top: topPosition,
      left: 0,
      right: 0,
      child: Center(
        child: Image.asset(
          'assets/logo.png',
          width: MediaQuery.of(context).size.width * 0.5,
          height: MediaQuery.of(context).size.width * 0.5,
        ),
      ),
    );
  }

  Widget _buildLoginContainer(double topPosition) {
    return Positioned(
      top: topPosition,
      left: MediaQuery.of(context).size.width * 0.05,
      right: MediaQuery.of(context).size.width * 0.05,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.4,  // Ajuste o tamanho do container conforme necessário
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
            const SizedBox(height: 10),
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
          FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: rememberMe,
            onChanged: (value) async {
              setState(() {
                rememberMe = value!;
              });

              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool('remember_me', rememberMe);

              if (!rememberMe) {
                prefs.remove('username');
                prefs.remove('password');
              }
            },
            checkColor: AppColors.auxiliaryColor,
            activeColor: AppColors.effectColor,
          ),
          SizedBox(width: 0),
          const Text(
            'Continuar conectado',
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: isButtonEnabled ? _login : null,
          icon: const Icon(Icons.login, color: AppColors.auxiliaryColor),
          label: const Text(
            'Entrar',
            style: TextStyle(
              color: AppColors.auxiliaryColor,
              overflow: TextOverflow.ellipsis,
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
