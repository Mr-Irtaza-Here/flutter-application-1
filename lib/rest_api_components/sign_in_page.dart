import 'package:flutter/material.dart';
import 'api_service.dart';
import 'session_manager.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool _obscurePassword = true;
  String? _usernameError;
  String? _passwordError;

  bool _validateInputs() {
    bool isValid = true;
    
    setState(() {
      // Validate username
      if (usernameController.text.trim().isEmpty) {
        _usernameError = 'Please enter your username';
        isValid = false;
      } else {
        _usernameError = null;
      }
      
      // Validate password
      if (passwordController.text.isEmpty) {
        _passwordError = 'Please enter your password';
        isValid = false;
      } else if (passwordController.text.length < 6) {
        _passwordError = 'Password must be at least 6 characters';
        isValid = false;
      } else {
        _passwordError = null;
      }
    });
    
    return isValid;
  }

  Future<void> _signIn() async {
    // Validate inputs first
    if (!_validateInputs()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiService.signIn(
        usernameController.text.trim(),
        passwordController.text.trim(),
      );

      if (!mounted) return;

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signed in successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
        debugPrint('Sign in response: ${response.toString()}');
        
        // Extract user data from server response
        final userData = response['data'];
        final clientData = userData?['client'];
        debugPrint('Client data from server: $clientData');
        
        // Get displayName from client object - this is what the server returns
        String displayName = clientData?['displayName'] ?? 
                             clientData?['user'] ?? 
                             usernameController.text.trim(); // fallback
        
        debugPrint('Display name: $displayName');
        
        // Save session data
        final String? token = userData?['token'];
        if (token != null) {
          await SessionManager.saveSession(
            token: token,
            displayName: displayName,
            userData: userData,
            clientData: clientData,
          );
        }
        
        // Navigate to Dashboard with name from server
        Navigator.pushReplacementNamed(
          context, 
          '/dashboard',
          arguments: {
            'username': displayName,
            'userData': userData,
            'clientData': clientData,
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Sign in failed'),
            backgroundColor: Colors.red,
          ),
        );
        debugPrint('Sign in failed: ${response.toString()}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Exception during sign in: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Username Field
              TextField(
                controller: usernameController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'Enter your username',
                  prefixIcon: const Icon(Icons.person_outlined),
                  border: const OutlineInputBorder(),
                  errorText: _usernameError,
                ),
              ),
              const SizedBox(height: 16),
              // Password Field
              TextField(
                controller: passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _signIn(),
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  border: const OutlineInputBorder(),
                  errorText: _passwordError,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Sign In Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _signIn,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Sign In',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
