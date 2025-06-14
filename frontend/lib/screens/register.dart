import 'package:flutter/material.dart';
import 'package:flutter_auth_app/screens/base_layout.dart';
import 'package:flutter_auth_app/services/auth_service.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  final void Function(String token)? onRegister; 

  const RegisterPage({super.key, this.onRegister});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ageController = TextEditingController(); // Controlador para la edad
  String? _selectedCountry; // Variable para almacenar el país seleccionado
  final List<String> _passwordErrors = []; // Lista de errores de la contraseña

  final AuthService _authService = AuthService(); 
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword); 
  }

  @override
  void dispose() {
    _passwordController.removeListener(_validatePassword);
    _passwordController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    final password = _passwordController.text;
    final errors = <String>[];

    if (password.isEmpty) {
      errors.add('La contraseña no puede estar vacía');
    }
    if (password.length < 8) {
      errors.add('Debe tener al menos 8 caracteres');
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      errors.add('Debe incluir al menos una letra minúscula');
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      errors.add('Debe incluir al menos una letra mayúscula');
    }
    if (!RegExp(r'\d').hasMatch(password)) {
      errors.add('Debe incluir al menos un número');
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      errors.add('Debe incluir al menos un símbolo');
    }
    if (_hasConsecutiveNumbers(password)) {
      errors.add('No debe contener números consecutivos');
    }

    setState(() {
      _passwordErrors.clear();
      _passwordErrors.addAll(errors);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Título
                const Text(
                  'Crea tu cuenta',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de Nombre
                FractionallySizedBox(
                  widthFactor: 0.5, // Ocupa el 50% del ancho de la pantalla
                  child: _buildTextField(
                    controller: _nameController,
                    label: 'Nombre',
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu nombre';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de Email
                FractionallySizedBox(
                  widthFactor: 0.5,
                  child: _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Por favor, ingresa un email válido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de Usuario
                FractionallySizedBox(
                  widthFactor: 0.5,
                  child: _buildTextField(
                    controller: _usernameController,
                    label: 'Usuario',
                    icon: Icons.account_circle,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu nombre de usuario';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de Contraseña
                FractionallySizedBox(
                  widthFactor: 0.5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Contraseña',
                        icon: Icons.lock,
                        obscureText: true,
                      ),
                      const SizedBox(height: 8),
                      ..._passwordErrors.map((error) => Text(
                            '- $error',
                            style: const TextStyle(color: Colors.red, fontSize: 14),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de Edad
                FractionallySizedBox(
                  widthFactor: 0.5,
                  child: _buildTextField(
                    controller: _ageController,
                    label: 'Edad',
                    icon: Icons.cake,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu edad';
                      }
                      final age = int.tryParse(value);
                      if (age == null || age <= 0 || age > 120) {
                        return 'Por favor, ingresa una edad válida';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de País
                FractionallySizedBox(
                  widthFactor: 0.5,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      canvasColor: Colors.grey[850], // Cambiar el color de fondo del picker
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedCountry,
                      decoration: InputDecoration(
                        labelText: 'País',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.grey[850],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color.fromARGB(255, 118, 194, 30)),
                        ),
                      ),
                      items: [
                        'Afganistán',
                        'Albania',
                        'Alemania',
                        'Andorra',
                        'Angola',
                        'Argentina',
                        'Australia',
                        'Austria',
                        'Bélgica',
                        'Bolivia',
                        'Brasil',
                        'Canadá',
                        'Chile',
                        'China',
                        'Colombia',
                        'Corea del Sur',
                        'Costa Rica',
                        'Cuba',
                        'Dinamarca',
                        'Ecuador',
                        'Egipto',
                        'El Salvador',
                        'Estados Unidos',
                        'Francia',
                        'Grecia',
                        'Guatemala',
                        'Honduras',
                        'India',
                        'Italia',
                        'Japón',
                        'México',
                        'Noruega',
                        'Panamá',
                        'Paraguay',
                        'Perú',
                        'Portugal',
                        'Reino Unido',
                        'Rusia',
                        'Spain',
                        'Suecia',
                        'Suiza',
                        'Uruguay',
                        'Venezuela',
                      ].map((country) {
                        return DropdownMenuItem(
                          value: country,
                          child: Text(
                            country,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCountry = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, selecciona tu país';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Botón de Registro
                _isLoading
                    ? const CircularProgressIndicator(color: Color.fromARGB(255, 118, 194, 30))
                    : FractionallySizedBox(
                        widthFactor: 0.5,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:  const Color.fromARGB(255, 98, 150, 38),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate() && _passwordErrors.isEmpty) {
                              final password = _passwordController.text.trim();

                              // Validar la contraseña con la API de Have I Been Pwned
                              final isPwned = await _isPasswordPwned(password);
                              if (isPwned) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Según la plataforma "Have I Been Pwned", esta contraseña ha sido comprometida. Por favor, elige otra.',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return; 
                              }

                              setState(() {
                                _isLoading = true;
                              });

                              // Continuar con el registro
                              final name = _nameController.text.trim();
                              final email = _emailController.text.trim();
                              final username = _usernameController.text.trim();
                              final age = int.parse(_ageController.text.trim());
                              final country = _selectedCountry!;
                              final success = await _authService.register(
                                name,
                                username,
                                password,
                                email,
                                age,
                                country,
                              );

                              if (success) {
                                // Intentar iniciar sesión automáticamente después del registro
                                final token = await _authService.login(username, password);

                                setState(() {
                                  _isLoading = false;
                                });

                                if (token != "") {
                                  if (widget.onRegister != null) {
                                    widget.onRegister!(token);
                                  }

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Registro exitoso'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );

                                  Navigator.of(context).pop();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Error al iniciar sesión después del registro'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } else {
                                setState(() {
                                  _isLoading = false;
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Error al registrar usuario'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Por favor, corrige los errores antes de continuar'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'Registrarse',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: const Color.fromARGB(255, 118, 194, 30)),
        filled: true,
        fillColor: Colors.grey[850],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color.fromARGB(255, 118, 194, 30)),
        ),
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }

  bool _hasConsecutiveNumbers(String value) {
    for (int i = 0; i < value.length - 1; i++) {
      if (int.tryParse(value[i]) != null &&
          int.tryParse(value[i + 1]) != null &&
          int.parse(value[i]) + 1 == int.parse(value[i + 1])) {
        return true;
      }
    }
    return false;
  }

  Future<bool> _isPasswordPwned(String password) async {
    // Calcular el hash SHA-1 de la contraseña
    final bytes = utf8.encode(password);
    final sha1Hash = sha1.convert(bytes).toString().toUpperCase();

    // Obtener los primeros 5 caracteres del hash
    final prefix = sha1Hash.substring(0, 5);
    final suffix = sha1Hash.substring(5);

    // Consultar la API de Have I Been Pwned
    final url = Uri.parse('https://api.pwnedpasswords.com/range/$prefix');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Buscar el sufijo en la respuesta
        final hashes = response.body.split('\n');
        for (final hash in hashes) {
          final parts = hash.split(':');
          if (parts[0] == suffix) {
            return true; // La contraseña ha sido comprometida
          }
        }
        return false; // La contraseña no ha sido encontrada
      } else {
        return false; // Asumir que no está comprometida si hay un error
      }
    } catch (e) {
      return false; // Asumir que no está comprometida si hay un error
    }
  }
}