import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../services/empresa_service.dart';
import 'home_screen.dart';

class CreateEmpresaScreen extends StatefulWidget {
  const CreateEmpresaScreen({Key? key}) : super(key: key);

  @override
  _CreateEmpresaScreenState createState() => _CreateEmpresaScreenState();
}

class _CreateEmpresaScreenState extends State<CreateEmpresaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _empresaService = EmpresaService();
  bool _isLoading = false;

  // Mapa de opciones de Razón Social
  final Map<String, String> _razonesSociales = {
    'Sociedad por Acciones Simplificada (S.A.S.)': 'S.A.S.',
    'Compañía de Responsabilidad Limitada (Cía. Ltda.)': 'Cía. Ltda.',
    'Sociedad Anónima (S.A.)': 'S.A.',
    'Compañía de Economía Mixta': 'Economía Mixta',
    'Compañía en Nombre Colectivo': 'Nombre Colectivo',
    'Compañía en Comandita (Simple o por Acciones)': 'Comandita',
  };

  final List<String> _sectores = ['Educación', 'Salud', 'Tecnología', 'Comercio', 'Finanzas', 'Alimentación', 'Otros'];

  String? _selectedRazonSocial;
  String? _selectedSector;

  // ==== DATOS EN CASCADA AUTOMÁTICOS ====
  final Map<String, Map<String, List<String>>> _locationData = {
    "Ecuador": {
      "Pichincha": ["Quito", "Cayambe", "Machachi", "Sangolquí"],
      "Guayas": ["Guayaquil", "Durán", "Samborondón", "Daule"],
      "Azuay": ["Cuenca", "Gualaceo", "Paute"],
      "Santo Domingo de los Tsáchilas": ["Santo Domingo", "La Concordia"],
      "Manabí": ["Manta", "Portoviejo", "Chone"],
      "Tungurahua": ["Ambato", "Baños", "Pelileo"],
      "Loja": ["Loja", "Catamayo"],
    },
    "Colombia": {
      "Bogotá D.C.": ["Bogotá"],
      "Antioquia": ["Medellín", "Bello", "Itagüí", "Envigado"],
      "Valle del Cauca": ["Cali", "Buenaventura", "Palmira"],
      "Atlántico": ["Barranquilla", "Soledad"],
    },
    "Perú": {
      "Lima": ["Lima", "Callao", "Miraflores"],
      "Arequipa": ["Arequipa"],
      "Cusco": ["Cusco"],
    }
  };

  String? _selectedPais;
  String? _selectedEstado;
  String? _selectedCiudad;

  List<String> get _estadosDisponibles {
    if (_selectedPais == null || !_locationData.containsKey(_selectedPais)) return [];
    return _locationData[_selectedPais]!.keys.toList();
  }

  List<String> get _ciudadesDisponibles {
    if (_selectedPais == null || _selectedEstado == null || !_locationData.containsKey(_selectedPais)) return [];
    final estados = _locationData[_selectedPais]!;
    if (!estados.containsKey(_selectedEstado)) return [];
    return estados[_selectedEstado]!;
  }

  // Formateador de máscara telefónica
  final _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '### ### ####', 
    filter: { "#": RegExp(r'[0-9]') },
    type: MaskAutoCompletionType.lazy
  );

  // Controladores de los campos de texto
  final _nombreController = TextEditingController();
  final _rucController = TextEditingController();
  final _direccionController = TextEditingController();
  final _correoController = TextEditingController();
  final _sitioWebController = TextEditingController();
  final _telefonoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Preseleccionar Ecuador por defecto
    _selectedPais = "Ecuador";
  }

  void _crearEmpresa() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedPais == null || _selectedEstado == null || _selectedCiudad == null) {
         ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, selecciona País, Provincia y Ciudad.')),
          );
         return;
      }

      setState(() {
        _isLoading = true;
      });

      Map<String, dynamic> data = {
        "nombreEmpresa": _nombreController.text,
        "razonSocial": _selectedRazonSocial,
        "ruc": _rucController.text,
        "ciudad": _selectedCiudad,
        "pais": _selectedPais,
        "direccion": _direccionController.text,
        "correoContacto": _correoController.text,
        "sector": _selectedSector,
        "sitioWeb": _sitioWebController.text,
        // Eliminamos los espacios antes de enviar a la BD
        "telefono": _telefonoController.text.replaceAll(' ', ''), 
      };

      bool success = await _empresaService.createEmpresa(data);

      setState(() {
        _isLoading = false;
      });

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Empresa registrada con éxito!')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al registrar la empresa')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _rucController.dispose();
    _direccionController.dispose();
    _correoController.dispose();
    _sitioWebController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Empresa')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Completa el perfil de tu empresa para continuar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre Comercial *'),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Razón Social *'),
                value: _selectedRazonSocial,
                items: _razonesSociales.keys.map((String key) {
                  return DropdownMenuItem<String>(
                    value: _razonesSociales[key],
                    child: Text(key, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRazonSocial = newValue;
                  });
                },
                validator: (value) => value == null ? 'Seleccione una razón social' : null,
              ),
              
              TextFormField(
                controller: _rucController,
                decoration: const InputDecoration(labelText: 'RUC / Identificación *'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(13),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requerido';
                  if (value.length != 10 && value.length != 13) {
                    return 'Debe tener 10 o 13 dígitos';
                  }
                  return null;
                },
              ),
              
              TextFormField(
                controller: _correoController,
                decoration: const InputDecoration(labelText: 'Correo de Contacto *'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requerido';
                  if (!value.contains('@')) return 'Correo inválido';
                  return null;
                },
              ),
              
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono *',
                  hintText: '099 999 9999'
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [_phoneMaskFormatter],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requerido';
                  // Verificamos la longitud total del texto incluyendo espacios (10 dígitos + 2 espacios)
                  if (value.length < 12) return 'Teléfono incompleto';
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              const Text('Ubicación *', style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.bold)),
              
              // País Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'País'),
                value: _selectedPais,
                items: _locationData.keys.map((String pais) {
                  return DropdownMenuItem<String>(
                    value: pais,
                    child: Text(pais),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPais = newValue;
                    _selectedEstado = null; // Reiniciar estado
                    _selectedCiudad = null; // Reiniciar ciudad
                  });
                },
                validator: (value) => value == null ? 'Requerido' : null,
              ),
              
              // Estado/Provincia Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Provincia/Estado'),
                value: _selectedEstado,
                items: _estadosDisponibles.map((String estado) {
                  return DropdownMenuItem<String>(
                    value: estado,
                    child: Text(estado),
                  );
                }).toList(),
                onChanged: _selectedPais == null ? null : (String? newValue) {
                  setState(() {
                    _selectedEstado = newValue;
                    _selectedCiudad = null; // Reiniciar ciudad al cambiar provincia
                  });
                },
                validator: (value) => value == null ? 'Requerido' : null,
              ),

              // Ciudad Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Ciudad'),
                value: _selectedCiudad,
                items: _ciudadesDisponibles.map((String ciudad) {
                  return DropdownMenuItem<String>(
                    value: ciudad,
                    child: Text(ciudad),
                  );
                }).toList(),
                onChanged: _selectedEstado == null ? null : (String? newValue) {
                  setState(() {
                    _selectedCiudad = newValue;
                  });
                },
                validator: (value) => value == null ? 'Requerido' : null,
              ),
              
              const SizedBox(height: 8),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(labelText: 'Dirección Exacta'),
              ),
              
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Sector',
                  hintText: 'ej. Educación, Salud'
                ),
                value: _selectedSector,
                items: _sectores.map((String sector) {
                  return DropdownMenuItem<String>(
                    value: sector,
                    child: Text(sector),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSector = newValue;
                  });
                },
              ),
              
              TextFormField(
                controller: _sitioWebController,
                decoration: const InputDecoration(labelText: 'Sitio Web'),
                keyboardType: TextInputType.url,
              ),
              
              const SizedBox(height: 30),
              
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _crearEmpresa,
                      child: const Text('Crear Empresa y Continuar'),
                    ),
                    
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                child: const Text('Saltar este paso (Ir al Dashboard)'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
