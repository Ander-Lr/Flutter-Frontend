import 'package:flutter/material.dart';
import '../models/cuenta_social.dart';
import '../services/social_account_service.dart';
import 'scraping_loading_screen.dart';

class SelectAccountScreen extends StatefulWidget {
  const SelectAccountScreen({Key? key}) : super(key: key);

  @override
  _SelectAccountScreenState createState() => _SelectAccountScreenState();
}

class _SelectAccountScreenState extends State<SelectAccountScreen> {
  final SocialAccountService _socialAccountService = SocialAccountService();
  List<CuentaSocial> _cuentas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCuentas();
  }

  Future<void> _fetchCuentas() async {
    final cuentas = await _socialAccountService.getCuentasSociales();
    if (mounted) {
      setState(() {
        _cuentas = cuentas;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Cuenta'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF11111B),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cuentas.isEmpty
              ? const Center(child: Text('No tienes cuentas para analizar.', style: TextStyle(color: Colors.white70)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _cuentas.length,
                  itemBuilder: (context, index) {
                    final cuenta = _cuentas[index];
                    return Card(
                      elevation: 0,
                      color: Colors.white.withOpacity(0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.white12),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.1),
                          backgroundImage: cuenta.imgUsuario != null 
                              ? NetworkImage(cuenta.imgUsuario!) 
                              : null,
                          child: cuenta.imgUsuario == null 
                              ? const Icon(Icons.person, color: Colors.white70) 
                              : null,
                        ),
                        title: Text(cuenta.nombreCuenta, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        subtitle: Text('${cuenta.redSocial.toUpperCase()} | ${cuenta.usuarioHandle}', style: TextStyle(color: Colors.grey.shade400)),
                        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                        onTap: () async {
                          // Navegar a la pantalla de carga
                          final jobId = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ScrapingLoadingScreen(cuenta: cuenta),
                            ),
                          );
                          
                          // Si retorna un JobID, cerramos esta pantalla y lo pasamos al Home
                          if (jobId != null) {
                            if (mounted) {
                              Navigator.pop(context, jobId);
                            }
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
