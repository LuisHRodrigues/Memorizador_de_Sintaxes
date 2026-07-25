import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../ideiasRandom/CardsDeCategorias.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final controllerEmail = TextEditingController();
  final controllerSenha = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _obscureText = true;
  bool _isLoading = false;
  bool _navigated = false;

  @override
  void dispose() {
    controllerEmail.dispose();
    controllerSenha.dispose();
    super.dispose();
  }

  // Login com email e senha
  Future<void> _loginEmailSenha() async {
    if (_isLoading || _navigated) return;

    setState(() => _isLoading = true);

    try {
      await _auth.signInWithEmailAndPassword(
        email: controllerEmail.text.trim(),
        password: controllerSenha.text.trim(),
      );

      _goToHome();
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Erro ao fazer login");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Login com Google (integrado ao FirebaseAuth)
  Future<void> _loginGoogle() async {
    if (_isLoading || _navigated) return;

    setState(() => _isLoading = true);

    try {
      final GoogleSignInAccount? googleUser =
      await _googleSignIn.signIn();

      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      _goToHome();
    } catch (e) {
      _showError("Erro no login com Google");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  //Navegação centralizada
  void _goToHome() {
    if (_navigated) return;
    _navigated = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const CardsDeCategorias(),
        ),
      );
    });
  }

  // Feedback de erro
  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  //Verifica sessão ativa automaticamente
  @override
  void initState() {
    super.initState();

    if (_auth.currentUser != null) {
      _goToHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CodeBit"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controllerEmail,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: controllerSenha,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: "Senha",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _isLoading ? null : _loginEmailSenha,
              child: const Text("Entrar"),
            ),

            const SizedBox(height: 10),

            IconButton(
              icon: SvgPicture.asset(
                'assets/icons/icons8-google-logo-50.svg',
                height: 30,
              ),
              onPressed: _isLoading ? null : _loginGoogle,
            ),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}