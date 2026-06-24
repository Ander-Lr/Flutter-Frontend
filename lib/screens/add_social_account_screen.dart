import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/social_account_service.dart';

class AddSocialAccountScreen extends StatefulWidget {
  const AddSocialAccountScreen({Key? key}) : super(key: key);

  @override
  _AddSocialAccountScreenState createState() => _AddSocialAccountScreenState();
}

class _AddSocialAccountScreenState extends State<AddSocialAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = SocialAccountService();
  bool _isLoading = false;

  // Estado para visibilidad de contraseñas
  bool _obscurePasswordRedSocial = true;
  bool _obscurePasswordRecuperacion = true;

  final _nombreController = TextEditingController();
  final _usuarioHandleController = TextEditingController();
  final _enlaceController = TextEditingController();
  final _descripcionController = TextEditingController();
  
  // Controles separados para generar los JSON internos
  final _userRedSocialController = TextEditingController();
  final _passwordRedSocialController = TextEditingController();
  final _emailRecuperacionController = TextEditingController();
  final _passwordRecuperacionController = TextEditingController();

  String _selectedRedSocial = 'instagram';

  void _guardarCuenta() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String credencialesRedSocial = jsonEncode({
        "user": _userRedSocialController.text,
        "password": _passwordRedSocialController.text
      });

      String credencialesCorreo = jsonEncode({
        "email": _emailRecuperacionController.text,
        "password": _passwordRecuperacionController.text
      });

      Map<String, dynamic> data = {
        "redSocial": _selectedRedSocial,
        "nombreCuenta": _nombreController.text,
        "usuarioHandle": _usuarioHandleController.text,
        "enlace": _enlaceController.text,
        "descripcion": _descripcionController.text,
        "credencialesRedSocial": credencialesRedSocial,
        "credencialesCorreoRecuperacion": credencialesCorreo,
      };

      bool success = await _service.createCuentaSocial(data);

      setState(() {
        _isLoading = false;
      });

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cuenta Social agregada con éxito')),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al agregar la cuenta')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _usuarioHandleController.dispose();
    _enlaceController.dispose();
    _descripcionController.dispose();
    _userRedSocialController.dispose();
    _passwordRedSocialController.dispose();
    _emailRecuperacionController.dispose();
    _passwordRecuperacionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Cuenta Social'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text('Información General', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70)),
              ),
              DropdownButtonFormField<String>(
                value: _selectedRedSocial,
                decoration: const InputDecoration(labelText: 'Plataforma *'),
                items: const [
                  DropdownMenuItem(value: 'instagram', child: Text('Instagram')),
                  DropdownMenuItem(value: 'facebook', child: Text('Facebook')),
                  DropdownMenuItem(value: 'X', child: Text('X (Twitter)')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRedSocial = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la Cuenta *',
                  hintText: 'Ej. Instagram Oficial',
                ),
                validator: (value) => value == null || value.isEmpty ? 'Este campo es requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usuarioHandleController,
                decoration: const InputDecoration(
                  labelText: 'Usuario / Handle',
                  hintText: 'Ej. @mi_marca',
                  helperText: 'Opcional',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _enlaceController,
                decoration: const InputDecoration(
                  labelText: 'Enlace al Perfil',
                  hintText: 'https://...',
                  helperText: 'Opcional',
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción / Propósito',
                  hintText: 'Breve descripción del uso de la cuenta',
                  helperText: 'Opcional',
                ),
                maxLines: 2,
              ),
              
              const SizedBox(height: 32),
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text('Credenciales de Acceso', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70)),
              ),
              
              Card(
                elevation: 0,
                color: Colors.white.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.white12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Red Social', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _userRedSocialController,
                        decoration: const InputDecoration(
                          labelText: 'Usuario *',
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordRedSocialController,
                        obscureText: _obscurePasswordRedSocial,
                        decoration: InputDecoration(
                          labelText: 'Contraseña *',
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePasswordRedSocial ? Icons.visibility : Icons.visibility_off, color: Colors.white54),
                            onPressed: () {
                              setState(() {
                                _obscurePasswordRedSocial = !_obscurePasswordRedSocial;
                              });
                            },
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              Card(
                elevation: 0,
                color: Colors.white.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.white12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Correo de Recuperación', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailRecuperacionController,
                        decoration: const InputDecoration(
                          labelText: 'Email *',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordRecuperacionController,
                        obscureText: _obscurePasswordRecuperacion,
                        decoration: InputDecoration(
                          labelText: 'Contraseña *',
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePasswordRecuperacion ? Icons.visibility : Icons.visibility_off, color: Colors.white54),
                            onPressed: () {
                              setState(() {
                                _obscurePasswordRecuperacion = !_obscurePasswordRecuperacion;
                              });
                            },
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _guardarCuenta,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Guardar Cuenta Social', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
