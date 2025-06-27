import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/theme_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart'; 
import 'screens/settings_screen.dart';
import 'screens/auth/login_screen.dart'; 
import 'services/auth_service.dart';
import 'screens/add_task_screen.dart'; 
import 'services/task_service.dart';
import 'screens/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => AuthService()), 
        Provider<TaskService>(create: (_) => TaskService()), 
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'Task Manager',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeNotifier.themeMode,
      initialRoute: '/', // Start the app with the AuthCheckScreen
      routes: {
        '/': (context) => AuthCheckScreen(), // Auth check route
        '/settings': (context) => SettingsPage(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/add_task': (context) => AddTaskScreen(),
        '/register': (context) => RegisterScreen(),
      },
    );
  }
}

class AuthCheckScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Check if the user is authenticated
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          // If the user is logged in, navigate to HomeScreen
          return HomeScreen();
        } else {
          // If the user is not logged in, navigate to LoginScreen
          return LoginScreen();
        }
      },
    );
  }
}
