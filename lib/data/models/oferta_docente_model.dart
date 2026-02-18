class OfertaDocenteModel {
  final int id;
  final int idSesion;
  final int idDocente;
  final double precioOfertado;
  final int duracionMinutos; // duración en minutos fijada por el docente
  final String? mensaje;
  final String estado;
  final DateTime? fechaOferta;

  // Relación: datos del docente
  final String? docenteNombre;
  final String? docenteFoto;
  final double? docenteRating;
  final String? docenteEspecialidad;

  OfertaDocenteModel({
    required this.id,
    required this.idSesion,
    required this.idDocente,
    required this.precioOfertado,
    this.duracionMinutos = 60,
    this.mensaje,
    this.estado = 'Pendiente',
    this.fechaOferta,
    this.docenteNombre,
    this.docenteFoto,
    this.docenteRating,
    this.docenteEspecialidad,
  });

  factory OfertaDocenteModel.fromJson(Map<String, dynamic> json) {
    final docente = json['docente'] as Map<String, dynamic>?;

    return OfertaDocenteModel(
      id: json['id_oferta'] as int,
      idSesion: json['id_sesion'] as int,
      idDocente: json['id_docente'] as int,
      precioOfertado: (json['precio_ofertado'] as num).toDouble(),
      duracionMinutos: json['duracion_minutos'] as int? ?? 60,
      mensaje: json['mensaje'] as String?,
      estado: json['estado'] as String? ?? 'Pendiente',
      fechaOferta: json['fecha_oferta'] != null
          ? DateTime.parse(json['fecha_oferta'] as String)
          : null,
      docenteNombre: docente != null
          ? '${docente['nombre']} ${docente['apellido']}'
          : null,
      docenteFoto: docente?['foto_perfil'] as String?,
      docenteRating: (docente?['rating_promedio'] as num?)?.toDouble(),
      docenteEspecialidad: docente?['biografia_corta'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id_sesion': idSesion,
    'id_docente': idDocente,
    'precio_ofertado': precioOfertado,
    'duracion_minutos': duracionMinutos,
    'mensaje': mensaje,
    'estado': estado,
  };

  /// Label para mostrar duración de forma legible
  String get duracionLabel {
    if (duracionMinutos >= 60) {
      final horas = duracionMinutos ~/ 60;
      final mins = duracionMinutos % 60;
      if (mins == 0) return '$horas hr';
      return '$horas hr $mins min';
    }
    return '$duracionMinutos min';
  }
}
