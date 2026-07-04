import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePin = true;

  static const String _validEmail = 'achtasougoudou@gmail.com';
  static const String _validPin = '2026';

  @override
  void dispose() {
    _emailController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _showBiometricDialog() {
    setState(() {
      _isLoading = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFF00A86B)),
            const SizedBox(height: 20),
            const Text(
              'Scan biométrique en cours...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop();
      setState(() {
        _isLoading = false;
      });
      Navigator.pushReplacementNamed(context, '/dashboard');
    });
  }

  void _validateCredentials() {
    final email = _emailController.text.trim();
    final pin = _pinController.text;

    if (email == _validEmail && pin == _validPin) {
      setState(() {
        _isLoading = true;
      });

      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _isLoading = false;
        });
        Navigator.pushReplacementNamed(context, '/dashboard');
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email ou PIN incorrect'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF00A86B).withOpacity(0.1),
                    const Color(0xFF00A86B).withOpacity(0.05),
                    Colors.white,
                  ],
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Container(
                      width: 400,
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_hospital,
                            size: 64,
                            color: const Color(0xFF00A86B),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Santé-Tchad',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: const Color(0xFF00A86B),
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Connexion sécurisée',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                          const SizedBox(height: 40),

                          if (!_isLoading) ...[
                            _buildEmailField(),
                            const SizedBox(height: 16),
                            _buildPinField(),
                            const SizedBox(height: 24),
                            _buildLoginButton(),
                            const SizedBox(height: 16),
                            _buildBiometricButton(),
                            const SizedBox(height: 24),
                            _buildDemoHint(),
                          ] else ...[
                            const CircularProgressIndicator(color: Color(0xFF00A86B)),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'votre@email.com',
              hintStyle: TextStyle(
                color: Colors.grey[400],
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              prefixIcon: Icon(
                Icons.email_outlined,
                color: Colors.grey[600],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPinField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Code PIN',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: _pinController,
            obscureText: _obscurePin,
            keyboardType: TextInputType.number,
            maxLength: 4,
            style: const TextStyle(
              fontSize: 24,
              letterSpacing: 8,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: '••••',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                letterSpacing: 8,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              counterText: '',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePin ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[600],
                ),
                onPressed: () {
                  setState(() {
                    _obscurePin = !_obscurePin;
                  });
                },
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _validateCredentials,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00A86B),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Se connecter',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDemoHint() {
    return Text(
      'Identifiants de démonstration : achtasougoudou@gmail.com | PIN : 2026',
      style: TextStyle(
        fontSize: 11,
        color: Colors.grey[400],
        fontStyle: FontStyle.italic,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildBiometricButton() {
    return InkWell(
      onTap: _isLoading ? null : _showBiometricDialog,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _isLoading
              ? Colors.grey[200]
              : const Color(0xFF00A86B).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF00A86B).withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fingerprint,
              color: const Color(0xFF00A86B),
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              _isLoading ? 'Scan en cours...' : 'Scan biométrique',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: _isLoading ? Colors.grey[600] : const Color(0xFF00A86B),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.verified_user,
            color: const Color(0xFF00A86B),
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            'Réalisé par Achta Sougoudou',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: Color(0xFF475569),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
