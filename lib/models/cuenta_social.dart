class CuentaSocial {
  final String idCuentaSocial;
  final String redSocial;
  final String nombreCuenta;
  final String usuarioHandle;
  final String? imgUsuario;
  final String enlace;
  final String? descripcion;
  final String? summary;
  final bool estadoActivo;
  final String? fechaCreacion;
  final String? empresaId;
  final bool hasCredencialesRedSocial;
  final bool hasCredencialesCorreoRecuperacion;

  CuentaSocial({
    required this.idCuentaSocial,
    required this.redSocial,
    required this.nombreCuenta,
    required this.usuarioHandle,
    this.imgUsuario,
    required this.enlace,
    this.descripcion,
    this.summary,
    required this.estadoActivo,
    this.fechaCreacion,
    this.empresaId,
    required this.hasCredencialesRedSocial,
    required this.hasCredencialesCorreoRecuperacion,
  });

  factory CuentaSocial.fromJson(Map<String, dynamic> json) {
    return CuentaSocial(
      idCuentaSocial: json['idCuentaSocial'] ?? '',
      redSocial: json['redSocial'] ?? 'instagram',
      nombreCuenta: json['nombreCuenta'] ?? '',
      usuarioHandle: json['usuarioHandle'] ?? '',
      imgUsuario: json['imgUsuario'],
      enlace: json['enlace'] ?? '',
      descripcion: json['descripcion'],
      summary: json['summary'],
      estadoActivo: json['estadoActivo'] ?? false,
      fechaCreacion: json['fechaCreacion'],
      empresaId: json['empresaId'],
      hasCredencialesRedSocial: json['hasCredencialesRedSocial'] ?? false,
      hasCredencialesCorreoRecuperacion: json['hasCredencialesCorreoRecuperacion'] ?? false,
    );
  }
}
