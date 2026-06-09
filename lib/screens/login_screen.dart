import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
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

    // Gọi API login thật với JWT response
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
    return Scaffold(
      backgroundColor: AromaColors.coffeeBackground,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),

                  // ── Logo with animated glow ──
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF8B6F47),
                          AromaColors.coffeePrimary,
                          Color(0xFF5A3D2B),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AromaColors.coffeePrimary.withOpacity(0.35),
                          blurRadius: 28,
                          offset: const Offset(0, 12),
                        ),
                        BoxShadow(
                          color: AromaColors.coffeeGold.withOpacity(0.15),
                          blurRadius: 40,
                          spreadRadius: 4,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "☕",
                      style: TextStyle(fontSize: 56),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // ── Title ──
                  const Text(
                    "QR ORDERING",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AromaColors.coffeePrimary,
                      fontFamily: 'Serif',
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: AromaColors.coffeePrimary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Dành cho Staff & Admin",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AromaColors.coffeePrimary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // ── Error Message ──
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _errorMessage.isNotEmpty
                        ? Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF0F0),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: Colors.red.shade200, width: 1.2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.error_outline,
                                      color: Colors.red.shade600, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _errorMessage,
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      height: 1.4,
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
                    label: "Tên đăng nhập hoặc Email",
                    icon: Icons.person_outline_rounded,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),

                  // ── Password Field ──
                  _buildInputField(
                    controller: _passwordController,
                    label: "Mật khẩu",
                    icon: Icons.lock_outline_rounded,
                    enabled: !_isLoading,
                    isPassword: true,
                  ),

                  const SizedBox(height: 36),

                  // ── Login Button ──
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AromaColors.coffeePrimary,
                        disabledBackgroundColor:
                            AromaColors.coffeePrimary.withOpacity(0.5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 6,
                        shadowColor:
                            AromaColors.coffeePrimary.withOpacity(0.35),
                      ),
                      child: _isLoading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  "ĐANG XỬ LÝ...",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            )
                          : const Text(
                              "ĐĂNG NHẬP",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Server status indicator ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AromaColors.successGreen,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AromaColors.successGreen.withOpacity(0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Kết nối: ${_getDisplayUrl()}",
                        style: TextStyle(
                          fontSize: 11,
                          color: AromaColors.coffeeTextSub.withOpacity(0.7),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getDisplayUrl() {
    final url = ApiService.baseUrl;
    // Rút gọn URL cho đẹp
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AromaColors.coffeePrimary.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        obscureText: isPassword ? _obscurePassword : false,
        onSubmitted: (_) {
          if (!_isLoading) _handleLogin();
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: AromaColors.coffeeTextSub,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            icon,
            color: AromaColors.coffeePrimary,
            size: 22,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: AromaColors.coffeeTextSub,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AromaColors.coffeeCardBorder,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AromaColors.coffeeCardBorder,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AromaColors.coffeePrimary,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
        style: const TextStyle(
          color: AromaColors.coffeeTextDark,
          fontSize: 15,
        ),
      ),
    );
  }
}
