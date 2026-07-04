import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../models/user_model.dart';
import '../../utils/colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedCity = 'N\'Djamena';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _isArabic = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<String> _cities = [
    'N\'Djamena',
    'Moundou',
    'Sarh',
    'Abéché',
    'Kélo',
    'Doba',
    'Bongor',
    'Koumra',
    'Am Timan',
    
  ];

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
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  String _getPasswordStrength(String password) {
    if (password.isEmpty) return '';
    if (password.length < 6) return 'Faible';
    if (password.length < 10) return 'Moyen';
    return 'Fort';
  }

  Color _getPasswordStrengthColor(String password) {
    final strength = _getPasswordStrength(password);
    if (strength == 'Faible') return Colors.red;
    if (strength == 'Moyen') return Colors.orange;
    if (strength == 'Fort') return Colors.green;
    return Colors.grey;
  }

  void _handleRegister() async {
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showErrorSnackBar(_isArabic ? 'يرجى ملء جميع الحقول' : 'Veuillez remplir tous les champs');
      return;
    }

    if (_phoneController.text.length < 8) {
      _showErrorSnackBar(_isArabic ? 'رقم الهاتف يجب أن يكون 8 أرقام على الأقل' : 'Le numéro de téléphone doit avoir au moins 8 chiffres');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorSnackBar(_isArabic ? 'كلمات المرور غير متطابقة' : 'Les mots de passe ne correspondent pas');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final usersBox = Hive.box<UserModel>('users');
      
      // Vérifier si le numéro existe déjà
      final existingUser = usersBox.values.firstWhere(
        (u) => u.telephone == _phoneController.text,
        orElse: () => throw Exception('Not found'),
      );

      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar(_isArabic ? 'رقم الهاتف موجود بالفعل' : 'Ce numéro de téléphone existe déjà');
    } catch (e) {
      // Utilisateur n'existe pas, on peut créer
      try {
        final usersBox = Hive.box<UserModel>('users');
        final hashedPassword = _hashPassword(_passwordController.text);
        final uuid = const Uuid();

        final newUser = UserModel(
          id: uuid.v4(),
          nom: _nameController.text,
          telephone: _phoneController.text,
          motDePasse: hashedPassword,
          ville: _selectedCity,
          dateInscription: DateTime.now(),
        );

        await usersBox.add(newUser);

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showSuccessSnackBar(_isArabic ? 'تم إنشاء الحساب بنجاح!' : 'Compte créé avec succès !');
          Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar(_isArabic ? 'حدث خطأ أثناء إنشاء الحساب' : 'Erreur lors de la création du compte');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return true;
      },
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
      height: MediaQuery.of(context).size.height * 0.30,
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
                    AppColors.primary.withOpacity(0.8),
                    AppColors.primaryLight,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.white),
              onPressed: () => Navigator.pop(context),
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
                  width: 70,
                  height: 70,
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
                    ],
                  ),
                  child: const Icon(
                    Icons.person_add,
                    size: 35,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _isArabic ? 'إنشاء حساب' : 'Créer un compte',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isArabic ? 'انضم إلى eSanté Tchad' : 'Rejoignez eSanté Tchad',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.white.withOpacity(0.7),
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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
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
            const SizedBox(height: 8),
            _buildNameField(),
            const SizedBox(height: 16),
            _buildPhoneField(),
            const SizedBox(height: 16),
            _buildPasswordField(),
            const SizedBox(height: 16),
            _buildConfirmPasswordField(),
            const SizedBox(height: 16),
            _buildCityDropdown(),
            const SizedBox(height: 24),
            _buildRegisterButton(),
            const SizedBox(height: 16),
            _buildLoginLink(),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: _isArabic ? 'الاسم الكامل' : 'Nom complet',
        labelStyle: const TextStyle(color: AppColors.primary),
        prefixIcon: const Icon(Icons.person, color: AppColors.primary),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          onChanged: (value) => setState(() {}),
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
        ),
        if (_passwordController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Row(
              children: [
                Text(
                  _isArabic 
                      ? 'القوة: ${_getPasswordStrength(_passwordController.text)}'
                      : 'Force: ${_getPasswordStrength(_passwordController.text)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: _getPasswordStrengthColor(_passwordController.text),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                ...List.generate(
                  _getPasswordStrength(_passwordController.text) == 'Faible' ? 1 : 
                  _getPasswordStrength(_passwordController.text) == 'Moyen' ? 2 : 3,
                  (index) => Container(
                    width: 8,
                    height: 4,
                    margin: const EdgeInsets.only(right: 2),
                    decoration: BoxDecoration(
                      color: _getPasswordStrengthColor(_passwordController.text),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      onChanged: (value) => setState(() {}),
      decoration: InputDecoration(
        labelText: _isArabic ? 'تأكيد كلمة المرور' : 'Confirmer le mot de passe',
        labelStyle: const TextStyle(color: AppColors.primary),
        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        suffixIcon: _confirmPasswordController.text.isNotEmpty &&
                _passwordController.text == _confirmPasswordController.text
            ? const Icon(Icons.check_circle, color: AppColors.primary)
            : IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textMedium,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
      ),
    );
  }

  Widget _buildCityDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCity,
      decoration: InputDecoration(
        labelText: _isArabic ? 'مدينتك' : 'Votre ville',
        labelStyle: const TextStyle(color: AppColors.primary),
        prefixIcon: const Icon(Icons.location_on, color: AppColors.primary),
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
      items: _cities.map((String city) {
        return DropdownMenuItem<String>(
          value: city,
          child: Text(city),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedCity = newValue!;
        });
      },
    );
  }

  Widget _buildRegisterButton() {
    return AnimatedScale(
      scale: _isLoading ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
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
              colors: [Color(0xFF0d3b6e), Color(0xFF1a6fa8)],
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
                    _isArabic ? 'إنشاء حسابي' : 'CRÉER MON COMPTE',
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

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(_isArabic ? 'لديك حساب بالفعل؟ ' : 'Déjà un compte ? '),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(
            _isArabic ? 'تسجيل الدخول' : 'Se connecter',
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
