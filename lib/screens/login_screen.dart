import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants.dart';
import '../models/account_model.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  final Function(AccountModel) onLoginSuccess;

  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _errorMessage = "";

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = "Vui lòng nhập tên đăng nhập và mật khẩu";
        _isLoading = false;
      });
      return;
    }

    final result = await ApiService.login(username, password);

    if (!mounted) return;

    if (result.isSuccess && result.account != null) {
      widget.onLoginSuccess(result.account!);
    } else {
      setState(() {
        _errorMessage =
            result.errorMessage ?? "Đăng nhập thất bại. Vui lòng thử lại.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AromaColors.coffeeBackground,
      body: Stack(
        children: [
          // Background Gradient Decoration
          Positioned(
            top: -size.width * 0.4,
            right: -size.width * 0.2,
            child: Container(
              width: size.width,
              height: size.width,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AromaColors.coffeePrimary.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Logo ──
                        Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AromaColors.coffeeSurface,
                              borderRadius: AromaStyles.radiusLarge,
                              boxShadow: AromaStyles.glowShadow,
                            ),
                            child: const Icon(
                              PhosphorIconsFill.coffee,
                              size: 48,
                              color: AromaColors.coffeePrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // ── Title ──
                        Text(
                          "AROMA BISTRO",
                          textAlign: TextAlign.center,
                          style: AromaTypography.h1,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Welcome back. Please sign in to continue.",
                          textAlign: TextAlign.center,
                          style: AromaTypography.bodyMedium.copyWith(
                            color: AromaColors.coffeeTextSub,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // ── Error Message ──
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOutBack,
                          child: _errorMessage.isNotEmpty
                              ? Container(
                                  margin: const EdgeInsets.only(bottom: 24),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AromaColors.errorRed.withOpacity(0.1),
                                    borderRadius: AromaStyles.radiusMedium,
                                    border: Border.all(
                                      color: AromaColors.errorRed.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        PhosphorIconsRegular.warningCircle,
                                        color: AromaColors.errorRed,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _errorMessage,
                                          style: AromaTypography.bodyMedium.copyWith(
                                            color: AromaColors.errorRed,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),

                        // ── Username Field ──
                        _buildInputField(
                          controller: _usernameController,
                          label: "Username or Email",
                          icon: PhosphorIconsRegular.user,
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 20),

                        // ── Password Field ──
                        _buildInputField(
                          controller: _passwordController,
                          label: "Password",
                          icon: PhosphorIconsRegular.lock,
                          enabled: !_isLoading,
                          isPassword: true,
                        ),

                        const SizedBox(height: 40),

                        // ── Login Button ──
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: Theme.of(context).elevatedButtonTheme.style,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text("SIGN IN"),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // ── Server status indicator ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AromaColors.successGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Connected to ${_getDisplayUrl()}",
                              style: AromaTypography.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDisplayUrl() {
    final url = ApiService.baseUrl;
    return url
        .replaceAll('https://', '')
        .replaceAll('http://', '')
        .replaceAll('.onrender.com', '');
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AromaStyles.radiusMedium,
        boxShadow: AromaStyles.softShadow,
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        obscureText: isPassword ? _obscurePassword : false,
        onSubmitted: (_) {
          if (!_isLoading) _handleLogin();
        },
        style: AromaTypography.bodyLarge,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            size: 22,
            color: AromaColors.coffeePrimary,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? PhosphorIconsRegular.eyeClosed
                        : PhosphorIconsRegular.eye,
                    color: AromaColors.coffeeTextSub,
                    size: 22,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}
