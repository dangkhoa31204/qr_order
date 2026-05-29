import 'package:flutter/material.dart';
import '../constants.dart';

class LoginScreen extends StatefulWidget {
  final Function(UserRole) onLoginSuccess;

  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _errorMessage = "";

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // Simulate login validation
    Future.delayed(const Duration(seconds: 1), () {
      if (username.isEmpty || password.isEmpty) {
        setState(() {
          _errorMessage = "Vui lòng nhập tên đăng nhập và mật khẩu";
          _isLoading = false;
        });
        return;
      }

      // Mock authentication - in real app, call API
      if (username == "staff" && password == "12345") {
        widget.onLoginSuccess(UserRole.staff);
      } else if (username == "customer" && password == "12345") {
        widget.onLoginSuccess(UserRole.customer);
      } else {
        setState(() {
          _errorMessage = "Tên đăng nhập hoặc mật khẩu không chính xác";
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AromaColors.coffeeBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                // Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AromaColors.coffeePrimary,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AromaColors.coffeePrimary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "☕",
                    style: TextStyle(fontSize: 52),
                  ),
                ),
                const SizedBox(height: 32),
                // Title
                const Text(
                  "AROMA BISTRO",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AromaColors.coffeePrimary,
                    fontFamily: 'Serif',
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Hệ thống Gọi món QR Code",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AromaColors.coffeeTextSub,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 48),
                // Error Message
                if (_errorMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_errorMessage.isNotEmpty) const SizedBox(height: 24),
                // Username Field
                TextField(
                  controller: _usernameController,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    labelText: "Tên đăng nhập",
                    labelStyle: const TextStyle(
                      color: AromaColors.coffeeTextSub,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.person,
                      color: AromaColors.coffeePrimary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AromaColors.coffeeCardBorder,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AromaColors.coffeePrimary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  style: const TextStyle(
                    color: AromaColors.coffeeTextDark,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 16),
                // Password Field
                TextField(
                  controller: _passwordController,
                  enabled: !_isLoading,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Mật khẩu",
                    labelStyle: const TextStyle(
                      color: AromaColors.coffeeTextSub,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: AromaColors.coffeePrimary,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AromaColors.coffeeTextSub,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AromaColors.coffeeCardBorder,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AromaColors.coffeePrimary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  style: const TextStyle(
                    color: AromaColors.coffeeTextDark,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                // Demo credentials text
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Demo: staff/12345 hoặc customer/12345",
                    style: TextStyle(
                      fontSize: 11,
                      color: AromaColors.coffeeTextSub.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AromaColors.coffeePrimary,
                      disabledBackgroundColor:
                          AromaColors.coffeePrimary.withOpacity(0.5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            "ĐĂNG NHẬP",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
