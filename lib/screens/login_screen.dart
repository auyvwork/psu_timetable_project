import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  const LoginScreen({super.key, this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _uController = TextEditingController();
  final _pController = TextEditingController();
  final _uFocus = FocusNode();
  final _pFocus = FocusNode();

  bool _isLoading = false;
  String? _errorMessage;

  final dio = Dio();
  final cookieJar = CookieJar();

  @override
  void initState() {
    super.initState();
    dio.interceptors.add(CookieManager(cookieJar));
  }

  @override
  void dispose() {
    _uController.dispose(); _pController.dispose();
    _uFocus.dispose(); _pFocus.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    if (_uController.text.trim().isEmpty || _pController.text.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() { _errorMessage = null; _isLoading = true; });

    try {
      const loginUrl = 'https://student.psu.ru/pls/stu_cus_et/stu.login';
      final response = await dio.post(
        loginUrl,
        data: {'p_username': _uController.text.trim(), 'p_password': _pController.text.trim()},
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          followRedirects: false,
          validateStatus: (status) => status! < 500,
          responseType: ResponseType.plain,
        ),
      );

      final String html = response.data.toString();
      bool isError = html.contains('Неверный логин') || html.contains('invalid password') || html.contains('p_username');

      if ((response.statusCode == 302 || response.statusCode == 200) && !isError) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', _uController.text.trim());
        await prefs.setString('password', _pController.text.trim());
        if (mounted) {
          widget.onLoginSuccess?.call();
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        setState(() => _errorMessage = 'Неверный логин или пароль');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Ошибка сети');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final bool isKeyVisible = keyboardHeight > 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // Основной контент
            Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 550),
                  curve: Curves.ease,
                  height: isKeyVisible
                      ? MediaQuery.of(context).size.height * 0.23
                      : MediaQuery.of(context).size.height * 0.3,
                  child: ClipPath(
                    clipper: CurveClipper(),
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xFFEFEFEF),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 80,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: SizedBox(
                                width: 312,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 150),
                                  opacity: isKeyVisible ? 0.0 : 1.0,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        "Етис 2.0",
                                        style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black),
                                      ),
                                      const Text(
                                        "По всем вопросам звоните по телефону 2396870.",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w300,
                                            color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: AnimatedPadding(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.only(bottom: keyboardHeight),
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        child: Center(
                          child: SizedBox(
                            width: 256,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  "Вход",
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.black),
                                ),
                                const SizedBox(height: 20),
                                _buildField("Логин", _uController, _uFocus, _pFocus),
                                const SizedBox(height: 20),
                                _buildField("Пароль", _pController, _pFocus, null, isPass: true),

                                if (_errorMessage != null)
                                  Container(
                                    margin: const EdgeInsets.only(top: 24),
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.info_outline, color: Colors.red, size: 16),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            _errorMessage!,
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              height: 1.2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 24),

                                SizedBox(
                                  width: double.infinity,
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _doLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4264EB),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      elevation: 0,
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                        : const Text("Войти", style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.all(8),
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    alignment: Alignment.centerLeft,
                                  ),
                                  child: const Text(
                                    "забыли пароль?",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal,
                                      color: Color(0xFF4264EB),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: 0.5,
                child: const Text(
                  "#от студентов для студентов",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4264EB),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, FocusNode focus, FocusNode? next, {bool isPass = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focus,
          obscureText: isPass,
          onSubmitted: (_) => next != null ? FocusScope.of(context).requestFocus(next) : _doLogin(),
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFFFFFFF),
            constraints: const BoxConstraints(maxHeight: 40),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.black, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF4264EB), width: 2.0),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
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
    Path path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(size.width / 2, size.height - 80, size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}