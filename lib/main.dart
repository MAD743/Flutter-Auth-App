import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: AuthScreen()));
}

// Screen that lets you Register or Login
class AuthScreen extends StatefulWidget {
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool showLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Auth App')),
      body: Center(
        child:
            showLogin
                ? LoginForm(switchView: toggleView)
                : RegisterForm(switchView: toggleView),
      ),
    );
  }

  void toggleView() {
    setState(() {
      showLogin = !showLogin;
    });
  }
}

class RegisterForm extends StatefulWidget {
  final VoidCallback switchView;
  RegisterForm({required this.switchView});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String msg = '';

  void register() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text,
        password: _pass.text,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (ctx) => ProfileScreen()),
      );
    } catch (e) {
      setState(() {
        msg = "Error: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Register", style: TextStyle(fontSize: 20)),
            TextFormField(
              controller: _email,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: _pass,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) register();
              },
              child: Text("Register"),
            ),
            TextButton(
              onPressed: widget.switchView,
              child: Text("Already have an account? Log in"),
            ),
            Text(msg, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  final VoidCallback switchView;
  LoginForm({required this.switchView});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String msg = '';

  void login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text,
        password: _pass.text,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (ctx) => ProfileScreen()),
      );
    } catch (e) {
      setState(() {
        msg = "Login failed";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Login", style: TextStyle(fontSize: 20)),
            TextFormField(
              controller: _email,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: _pass,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) login();
              },
              child: Text("Login"),
            ),
            TextButton(
              onPressed: widget.switchView,
              child: Text("Don't have an account? Register"),
            ),
            Text(msg, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}

// Profile screen after login
class ProfileScreen extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser;

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (ctx) => AuthScreen()),
    );
  }

  void changePassword(BuildContext context) async {
    final newPass = TextEditingController();
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Change Password"),
            content: TextField(
              controller: newPass,
              obscureText: true,
              decoration: InputDecoration(labelText: "New Password"),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (newPass.text.length >= 6) {
                    await user?.updatePassword(newPass.text);
                    Navigator.pop(context);
                  }
                },
                child: Text("Change"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome!"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Logged in as: ${user?.email}"),
            ElevatedButton(
              onPressed: () => changePassword(context),
              child: Text("Change Password"),
            ),
          ],
        ),
      ),
    );
  }
}
