class KpiMetrics {
  final int totalAnalizado;
  final double porcentajeSpam;
  final double porcentajeRevision;
  final double porcentajeNegativo;

  KpiMetrics({
    required this.totalAnalizado,
    required this.porcentajeSpam,
    required this.porcentajeRevision,
    required this.porcentajeNegativo,
  });

  factory KpiMetrics.fromJson(Map<String, dynamic> json) {
    return KpiMetrics(
      totalAnalizado: json['totalAnalizado'] ?? 0,
      porcentajeSpam: (json['porcentajeSpam'] ?? 0.0).toDouble(),
      porcentajeRevision: (json['porcentajeRevision'] ?? 0.0).toDouble(),
      porcentajeNegativo: (json['porcentajeNegativo'] ?? 0.0).toDouble(),
    );
  }
}

class SentimentDistribution {
  final String sentimiento;
  final int cantidad;

  SentimentDistribution({required this.sentimiento, required this.cantidad});

  factory SentimentDistribution.fromJson(Map<String, dynamic> json) {
    return SentimentDistribution(
      sentimiento: json['sentimiento'] ?? 'neutro',
      cantidad: json['cantidad'] ?? 0,
    );
  }
}

class ToxicPublication {
  final String idPublicacion;
  final String autor;
  final String contenido;
  final double toxicidadScore;
  final DateTime? fechaPublicacion;

  ToxicPublication({
    required this.idPublicacion,
    required this.autor,
    required this.contenido,
    required this.toxicidadScore,
    this.fechaPublicacion,
  });

  factory ToxicPublication.fromJson(Map<String, dynamic> json) {
    return ToxicPublication(
      idPublicacion: json['idPublicacion'] ?? '',
      autor: json['autor'] ?? 'Desconocido',
      contenido: json['contenido'] ?? '',
      toxicidadScore: (json['toxicidadScore'] ?? 0.0).toDouble(),
      fechaPublicacion: json['fechaPublicacion'] != null 
          ? DateTime.tryParse(json['fechaPublicacion']) 
          : null,
    );
  }
}

class SentimentEvolution {
  final String fecha; // formato YYYY-MM-DD
  final String sentimiento;
  final int cantidad;

  SentimentEvolution({
    required this.fecha,
    required this.sentimiento,
    required this.cantidad,
  });

  factory SentimentEvolution.fromJson(Map<String, dynamic> json) {
    return SentimentEvolution(
      fecha: json['fecha'] ?? '',
      sentimiento: json['sentimiento'] ?? 'neutro',
      cantidad: json['cantidad'] ?? 0,
    );
  }
}

class SpamVolume {
  final int hora;
  final int cantidad;

  SpamVolume({required this.hora, required this.cantidad});

  factory SpamVolume.fromJson(Map<String, dynamic> json) {
    return SpamVolume(
      hora: json['hora'] ?? 0,
      cantidad: json['cantidad'] ?? 0,
    );
  }
}

class WorkerStatus {
  final int enCola;
  final int conError;
  final DateTime? ultimaActualizacion;
  final String modeloActivo;

  WorkerStatus({
    required this.enCola,
    required this.conError,
    this.ultimaActualizacion,
    required this.modeloActivo,
  });

  factory WorkerStatus.fromJson(Map<String, dynamic> json) {
    return WorkerStatus(
      enCola: json['enCola'] ?? 0,
      conError: json['conError'] ?? 0,
      ultimaActualizacion: json['ultimaActualizacion'] != null 
          ? DateTime.tryParse(json['ultimaActualizacion']) 
          : null,
      modeloActivo: json['modeloActivo'] ?? 'Desconocido',
    );
  }
}

class ReviewInboxItem {
  final String idComentario;
  final String autor;
  final String? imgAutor;
  final String contenido;
  final String sentimiento;
  final double sentimientoScore;
  final double toxicidadScore;
  final bool esSpam;
  final Map<String, dynamic>? analisisJson;
  final DateTime? fechaAnalisis;

  ReviewInboxItem({
    required this.idComentario,
    required this.autor,
    this.imgAutor,
    required this.contenido,
    required this.sentimiento,
    required this.sentimientoScore,
    required this.toxicidadScore,
    required this.esSpam,
    this.analisisJson,
    this.fechaAnalisis,
  });

  factory ReviewInboxItem.fromJson(Map<String, dynamic> json) {
    return ReviewInboxItem(
      idComentario: json['idComentario'] ?? '',
      autor: json['autor'] ?? 'Usuario',
      imgAutor: json['imgAutor'],
      contenido: json['contenido'] ?? '',
      sentimiento: json['sentimiento'] ?? 'neutro',
      sentimientoScore: (json['sentimientoScore'] ?? 0.0).toDouble(),
      toxicidadScore: (json['toxicidadScore'] ?? 0.0).toDouble(),
      esSpam: json['esSpam'] ?? false,
      analisisJson: json['analisisJson'],
      fechaAnalisis: json['fechaAnalisis'] != null 
          ? DateTime.tryParse(json['fechaAnalisis']) 
          : null,
    );
  }
}
