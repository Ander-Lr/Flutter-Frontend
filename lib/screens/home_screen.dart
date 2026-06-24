import 'package:flutter/material.dart';
import '../models/cuenta_social.dart';
import '../services/social_account_service.dart';
import 'add_social_account_screen.dart';
import 'select_account_screen.dart';
import '../widgets/analytical_dashboard.dart';
import 'profile_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SocialAccountService _socialAccountService = SocialAccountService();
  List<CuentaSocial> _cuentas = [];
  bool _isLoading = true;

  int _currentIndex = 0;
  String? _activeJobId; // Almacena el ID del trabajo si hay un scraping en curso
  Key _dashboardKey = UniqueKey(); // Para forzar recarga del dashboard

  @override
  void initState() {
    super.initState();
    _fetchCuentas();
  }

  Future<void> _fetchCuentas() async {
    setState(() {
      _isLoading = true;
    });
    
    final cuentas = await _socialAccountService.getCuentasSociales();
    
    if (mounted) {
      setState(() {
        _cuentas = cuentas;
        _isLoading = false;
      });
    }
  }

  Widget _buildScrapingLoadingDashboard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF9D4EDD).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFC77DFF)),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Análisis de IA en curso...',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Preparando tu nuevo Dashboard', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white70)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 4,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: const Color(0xFF1E1E2E).withOpacity(0.5),
                  child: const SizedBox(height: 80), // Skeleton card
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Future<void> _waitForScraping() async {
    // Simulamos que el worker termina de analizar después de 12 segundos
    await Future.delayed(const Duration(seconds: 12));
    if (mounted) {
      setState(() {
        _activeJobId = null;
        _dashboardKey = UniqueKey(); // Fuerza recarga del dashboard con nuevos datos
      });
    }
  }

  Widget _buildDashboard() {
    if (_activeJobId != null) {
      return _buildScrapingLoadingDashboard();
    }

    Widget cuentasWidget = _isLoading
        ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
        : _cuentas.isEmpty
            ? const Padding(padding: EdgeInsets.all(16), child: Text('No tienes cuentas sociales agregadas.'))
            : SizedBox(
                height: 100, // Alto para la lista horizontal de cuentas
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _cuentas.length,
                  itemBuilder: (context, index) {
                    final cuenta = _cuentas[index];
                    return Card(
                      color: const Color(0xFF1E1E2E),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                      child: Container(
                        width: 250, // Ancho fijo por tarjeta
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(0xFFC77DFF).withOpacity(0.2),
                              backgroundImage: cuenta.imgUsuario != null 
                                  ? NetworkImage(cuenta.imgUsuario!) 
                                  : null,
                              child: cuenta.imgUsuario == null 
                                  ? const Icon(Icons.person, color: Color(0xFFC77DFF)) 
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(cuenta.nombreCuenta, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  Text(cuenta.usuarioHandle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                                ],
                              ),
                            ),
                            Icon(
                              cuenta.estadoActivo ? Icons.check_circle : Icons.cancel,
                              color: cuenta.estadoActivo ? Colors.greenAccent : Colors.redAccent,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );

    final content = Column(
      children: [
        cuentasWidget,
        // El nuevo dashboard analítico
        Expanded(child: AnalyticalDashboard(key: _dashboardKey)),
      ],
    );

    return Stack(
      children: [
        content,
        Positioned(
          bottom: 16.0,
          right: 16.0,
          child: FloatingActionButton(
            heroTag: 'addSocialAccountBtn',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddSocialAccountScreen()),
              );
              if (result == true) {
                _fetchCuentas();
              }
            },
            backgroundColor: const Color(0xFF9D4EDD),
            foregroundColor: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildProfile() {
    return const ProfileScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'Dashboard' : 'Perfil'),
        actions: _currentIndex == 0 && _activeJobId == null ? [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchCuentas,
          )
        ] : null,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboard(),
          _buildProfile(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF1E1E2E), // Tono morado claro (Material 3 surface)
        elevation: 8,
        child: SizedBox(
          height: 60.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Botón Home
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _currentIndex = 0;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _currentIndex == 0 ? Icons.home : Icons.home_outlined,
                        color: _currentIndex == 0 ? const Color(0xFFC77DFF) : Colors.white54,
                        size: 26,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Home',
                        style: TextStyle(
                          color: _currentIndex == 0 ? const Color(0xFFC77DFF) : Colors.white54,
                          fontSize: 12,
                          fontWeight: _currentIndex == 0 ? FontWeight.bold : FontWeight.normal,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              
              // Botón Central (FAB integrado directamente en el Row para evitar bugs de Scaffold en Linux)
              FloatingActionButton(
                heroTag: 'centerFabBtn',
                onPressed: _activeJobId != null ? null : () async {
                  // Navega a la pantalla de seleccionar cuenta para scraping
                  final jobId = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SelectAccountScreen()),
                  );
                  
                  if (jobId != null) {
                    setState(() {
                      _activeJobId = jobId;
                      _currentIndex = 0; // Forza volver a Home
                    });
                    _waitForScraping();
                  }
                },
                backgroundColor: _activeJobId != null ? Colors.black45 : const Color(0xFF9D4EDD),
                foregroundColor: _activeJobId != null ? Colors.white38 : Colors.white,
                shape: const CircleBorder(),
                elevation: _activeJobId != null ? 0 : 4,
                child: const Icon(Icons.add, size: 28),
              ),

              // Botón Perfil
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _currentIndex = 1;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _currentIndex == 1 ? Icons.person : Icons.person_outline,
                        color: _currentIndex == 1 ? const Color(0xFFC77DFF) : Colors.white54,
                        size: 26,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Perfil',
                        style: TextStyle(
                          color: _currentIndex == 1 ? const Color(0xFFC77DFF) : Colors.white54,
                          fontSize: 12,
                          fontWeight: _currentIndex == 1 ? FontWeight.bold : FontWeight.normal,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
