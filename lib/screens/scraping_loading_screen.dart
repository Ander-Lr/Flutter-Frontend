import 'package:flutter/material.dart';
import '../models/cuenta_social.dart';
import '../services/scraping_service.dart';

class ScrapingLoadingScreen extends StatefulWidget {
  final CuentaSocial cuenta;

  const ScrapingLoadingScreen({Key? key, required this.cuenta}) : super(key: key);

  @override
  _ScrapingLoadingScreenState createState() => _ScrapingLoadingScreenState();
}

class _ScrapingLoadingScreenState extends State<ScrapingLoadingScreen> {
  final ScrapingService _scrapingService = ScrapingService();
  bool _isCancelled = false;
  String _statusMessage = 'Preparando análisis...';

  @override
  void initState() {
    super.initState();
    _startProcess();
  }

  Future<void> _startProcess() async {
    // 1. Retraso intencional para permitir cancelación
    await Future.delayed(const Duration(seconds: 3));

    if (_isCancelled) return;

    setState(() {
      _statusMessage = 'Conectando con el servidor...';
    });

    // 2. Hacer la petición al backend
    final response = await _scrapingService.startScraping(widget.cuenta.idCuentaSocial);

    if (_isCancelled) return; // Por si canceló justo durante la petición

    if (response != null && response['id'] != null) {
      // Éxito, retornamos el jobId
      if (mounted) {
        Navigator.pop(context, response['id']);
      }
    } else {
      // Error
      setState(() {
        _statusMessage = 'Error al iniciar el análisis.';
      });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pop(context, null);
      }
    }
  }

  void _cancel() {
    setState(() {
      _isCancelled = true;
    });
    Navigator.pop(context, null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF11111B),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF512DA8)),
                strokeWidth: 4,
              ),
              const SizedBox(height: 32),
              Text(
                _statusMessage,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Analizando: ${widget.cuenta.nombreCuenta}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 48),
              OutlinedButton.icon(
                onPressed: _cancel,
                icon: const Icon(Icons.close, color: Colors.redAccent),
                label: const Text('Cancelar', style: TextStyle(color: Colors.redAccent)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
