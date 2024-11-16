import 'pages/imports.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: AppColors.primaryColor,
        scaffoldBackgroundColor: AppColors.auxiliaryColor,
        iconTheme: IconThemeData(color: AppColors.secondaryColor),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: AppColors.secondaryColor),
          bodyMedium: TextStyle(color: AppColors.secondaryColor),
        ),
      ),
      home: const LoginPage(),
    );
  }
}
