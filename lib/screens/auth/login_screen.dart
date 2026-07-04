import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';
import '../../utils/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isArabic = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  void _handleLogin() async {
    if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorSnackBar(_isArabic ? 'يرجى ملء جميع الحقول' : 'Veuillez remplir tous les champs');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final usersBox = Hive.box<UserModel>('users');
      final hashedPassword = _hashPassword(_passwordController.text);
      
      final user = usersBox.values.firstWhere(
        (u) => u.telephone == _phoneController.text && u.motDePasse == hashedPassword,
        orElse: () => throw Exception('User not found'),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userId', user.id);
      await prefs.setString('userName', user.nom);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar(_isArabic ? 'رقم الهاتف أو كلمة المرور غير صحيحة' : 'Numéro ou mot de passe incorrect');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _handleContinueWithoutAccount() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppColors.backgroundGrey,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Directionality(
              textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
              child: Column(
                children: [
                  _buildHeaderSection(),
                  _buildFormCard(),
                  _buildOfflineBadge(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.35,
      child: Stack(
        children: [
          ClipPath(
            clipper: _WaveClipper(),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryDark,
                    AppColors.primary,
                    AppColors.primaryLight,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Row(
              children: [
                _buildLanguageButton('FR', false),
                const SizedBox(width: 8),
                _buildLanguageButton('ع', true),
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.white,
                        AppColors.white.withOpacity(0.9),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 25,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: AppColors.white.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_hospital,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'e_santé Tchad',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.white.withOpacity(0.3)),
                  ),
                  child: Text(
                    _isArabic ? 'صحتك، أولويتنا' : 'Votre santé, notre priorité',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageButton(String text, bool isArabicBtn) {
    final isActive = (isArabicBtn && _isArabic) || (!isArabicBtn && !_isArabic);
    return GestureDetector(
      onTap: () {
        setState(() {
          _isArabic = isArabicBtn;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? AppColors.primaryDark : AppColors.white,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isArabic ? 'مرحباً بعودتك' : 'Bon retour !',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _isArabic ? 'سجّل دخولك إلى حسابك' : 'Connectez-vous à votre compte',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMedium,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildPhoneField(),
            const SizedBox(height: 20),
            _buildPasswordField(),
            const SizedBox(height: 16),
            _buildRememberMeRow(),
            const SizedBox(height: 28),
            _buildLoginButton(),
            const SizedBox(height: 20),
            _buildSeparator(),
            const SizedBox(height: 20),
            _buildContinueWithoutAccountButton(),
            const SizedBox(height: 24),
            _buildRegisterLink(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return TextField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: _isArabic ? 'رقم الهاتف' : 'Numéro de téléphone',
        labelStyle: const TextStyle(color: AppColors.primary),
        prefixIcon: const Icon(Icons.phone, color: AppColors.primary),
        prefixText: '+235 ',
        prefixStyle: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: _isArabic ? 'كلمة المرور' : 'Mot de passe',
        labelStyle: const TextStyle(color: AppColors.primary),
        prefixIcon: const Icon(Icons.lock, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: AppColors.textMedium,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
    );
  }

  Widget _buildRememberMeRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: false,
              onChanged: (value) {},
              activeColor: AppColors.primary,
            ),
            Text(
              _isArabic ? 'تذكرني' : 'Se souvenir de moi',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            _isArabic ? 'نسيت كلمة المرور؟' : 'Mot de passe oublié ?',
            style: const TextStyle(
              color: AppColors.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return AnimatedScale(
      scale: _isLoading ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          backgroundColor: Colors.transparent,
          shadowColor: AppColors.primary.withOpacity(0.4),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryDark, AppColors.primary],
            ),
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                    ),
                  )
                : Text(
                    _isArabic ? 'تسجيل الدخول' : 'SE CONNECTER',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeparator() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.border,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            _isArabic ? 'أو' : 'OU',
            style: TextStyle(color: AppColors.textMedium),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.border,
          ),
        ),
      ],
    );
  }

  Widget _buildContinueWithoutAccountButton() {
    return Column(
      children: [
        OutlinedButton.icon(
          onPressed: _handleContinueWithoutAccount,
          icon: const Icon(Icons.person_off, color: AppColors.primary),
          label: Text(
            _isArabic ? 'المتابعة بدون حساب' : 'Continuer sans compte',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isArabic ? 'بياناتك تبقى على هاتفك' : 'Vos données restent sur votre téléphone',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textMedium,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(_isArabic ? 'ليس لديك حساب؟ ' : 'Pas de compte ? '),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/register');
          },
          child: Text(
            _isArabic ? 'إنشاء حساب' : 'Créer un compte',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOfflineBadge() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off, color: AppColors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            _isArabic ? 'يعمل بدون اتصال بالإنترنت' : 'Fonctionne sans connexion internet',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 50,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
