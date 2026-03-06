import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.onLoginSuccess});

  final VoidCallback? onLoginSuccess;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _uController = TextEditingController();
  final TextEditingController _pController = TextEditingController();
  final FocusNode _uFocus = FocusNode();
  final FocusNode _pFocus = FocusNode();

  final Dio dio = Dio();
  final CookieJar cookieJar = CookieJar();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    dio.interceptors.add(CookieManager(cookieJar));
    _uController.addListener(_onFieldsChanged);
    _pController.addListener(_onFieldsChanged);
  }

  @override
  void dispose() {
    _uController.dispose();
    _pController.dispose();
    _uFocus.dispose();
    _pFocus.dispose();
    super.dispose();
  }

  void _onFieldsChanged() {
    if (!mounted) return;
    setState(() {});
  }

  bool get _canSubmit =>
      _uController.text.trim().isNotEmpty &&
      _pController.text.trim().isNotEmpty &&
      !_isLoading;

  Future<void> _doLogin() async {
    if (!_canSubmit) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      const String loginUrl = 'https://student.psu.ru/pls/stu_cus_et/stu.login';
      final Response<dynamic> response = await dio.post<dynamic>(
        loginUrl,
        data: <String, dynamic>{
          'p_username': _uController.text.trim(),
          'p_password': _pController.text.trim(),
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          followRedirects: false,
          validateStatus: (int? status) => status != null && status < 500,
          responseType: ResponseType.plain,
        ),
      );

      final String html = response.data.toString();
      final bool isError = html.contains('Неверный логин') ||
          html.contains('invalid password') ||
          html.contains('p_username');

      if ((response.statusCode == 302 || response.statusCode == 200) &&
          !isError) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', _uController.text.trim());
        await prefs.setString('password', _pController.text.trim());
        if (!mounted) return;
        widget.onLoginSuccess?.call();
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() => _errorMessage = 'Неверный логин или пароль');
      }
    } catch (_) {
      setState(() => _errorMessage = 'Ошибка сети. Попробуйте еще раз.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final bool isKeyboardVisible = keyboardHeight > 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness:
            theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 550),
                  curve: Curves.ease,
                  height: isKeyboardVisible
                      ? MediaQuery.of(context).size.height * 0.20
                      : MediaQuery.of(context).size.height * 0.3,
                  child: ClipPath(
                    clipper: CurveClipper(),
                    child: Container(
                      width: double.infinity,
                      color: colorScheme.secondaryContainer.withOpacity(0.5),
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            top: 80,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: SizedBox(
                                width: 312,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 150),
                                  opacity: isKeyboardVisible ? 0.0 : 1.0,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        'Етис 2.0',
                                        style: theme.textTheme.headlineMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'По всем вопросам звоните по телефону 2396870.',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w300,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 20,
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 256,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Вход',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildField(
                                  label: 'Логин',
                                  controller: _uController,
                                  focusNode: _uFocus,
                                  nextFocus: _pFocus,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const <String>[
                                    AutofillHints.username,
                                  ],
                                ),
                                const SizedBox(height: 20),
                                _buildField(
                                  label: 'Пароль',
                                  controller: _pController,
                                  focusNode: _pFocus,
                                  isPassword: true,
                                  isPasswordVisible: _isPasswordVisible,
                                  onTogglePasswordVisibility: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => _doLogin(),
                                  autofillHints: const <String>[
                                    AutofillHints.password,
                                  ],
                                ),
                                if (_errorMessage != null)
                                  Container(
                                    margin: const EdgeInsets.only(top: 24),
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.errorContainer.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.info_outline,
                                          color: colorScheme.error,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            _errorMessage!,
                                            style: TextStyle(
                                              color: colorScheme.error,
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
                                  height: 44,
                                  child: ElevatedButton(
                                    onPressed: _canSubmit ? _doLogin : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      foregroundColor: colorScheme.onPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: _isLoading
                                        ? SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: colorScheme.onPrimary,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'Войти',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Для восстановления доступа обратитесь в деканат или по телефону 2396870.',
                                        ),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: colorScheme.primary,
                                    padding: const EdgeInsets.all(8),
                                  ),
                                  child: const Text(
                                    'забыли пароль?',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
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
                opacity: 0.7,
                child: Text(
                  '#от студентов для студентов',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    bool isPassword = false,
    bool isPasswordVisible = false,
    void Function(String)? onSubmitted,
    VoidCallback? onTogglePasswordVisibility,
    List<String>? autofillHints,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: isPassword && !isPasswordVisible,
          enableSuggestions: !isPassword,
          autocorrect: !isPassword,
          autofillHints: autofillHints,
          onSubmitted: (String value) {
            if (onSubmitted != null) {
              onSubmitted(value);
            } else if (nextFocus != null) {
              FocusScope.of(context).requestFocus(nextFocus);
            }
          },
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            constraints: const BoxConstraints(maxHeight: 45),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    onPressed: onTogglePasswordVisibility,
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      size: 18,
                    ),
                  )
                : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: colorScheme.outline,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: colorScheme.primary,
                width: 2.0,
              ),
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
    final Path path = Path()
      ..lineTo(0, size.height)
      ..quadraticBezierTo(
        size.width / 2,
        size.height - 80,
        size.width,
        size.height,
      )
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}