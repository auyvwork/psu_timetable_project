import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _uController = TextEditingController();
  final _pController = TextEditingController();

  void _doLogin() async {
    if (_uController.text.isEmpty || _pController.text.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _uController.text.trim());
    await prefs.setString('password', _pController.text.trim());

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(color: Colors.white),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.width * 0.7,
            child: ClipPath(
              clipper: CurveClipper(),
              child: Container(color: const Color(0xFFF2F2F2)),
            ),
          ),
          SafeArea(
            child: Center(
              child: SizedBox(
                width: 312,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 48),
                        const Text(
                          "Етис 2.0",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                        ),
                        const Text(
                          "По всем вопросам звоните по телефону 2396870.",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                    const Spacer(flex: 3),
                    Container(
                      width: 256,
                      child: Column(
                        children: [
                          const Text(
                            "Вход",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 24),
                          _field("Email", false),
                          _field("Password", true),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {_doLogin();},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4264EB),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                              child: const Text(
                                "Войти",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF4264EB),
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              "Забыли пароль?",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(flex: 3),
                    const Text(
                      "#от студентов для студентов",
                      style: TextStyle(
                        color: Color(0xFF4264EB),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, bool isPass) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 8),
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          obscureText: isPass,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.grey, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.blue, width: 2.0),
            ),
          ),
        ),
      ],
    );
  }
}

class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(0, size.height)
      ..quadraticBezierTo(size.width / 2, size.height - 70, size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(old) => false;
}