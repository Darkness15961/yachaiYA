class SesionModel {
  final int id;
  final int idEstudiante;
  final int? idDocente;
  final int idMateria;
  final String? temaDescripcion;
  final String estado;
  final String modalidad;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final double costoTotal;

  // Relaciones opcionales
  final String? docenteNombre;
  final String? materiaNombre;

  SesionModel({
    required this.id,
    required this.idEstudiante,
    this.idDocente,
    required this.idMateria,
    this.temaDescripcion,
    this.estado = 'Buscando',
    this.modalidad = 'Solo_Chat',
    this.fechaInicio,
    this.fechaFin,
    this.costoTotal = 0.0,
    this.docenteNombre,
    this.materiaNombre,
  });

  factory SesionModel.fromJson(Map<String, dynamic> json) {
    // Soporte para joins
    final docente = json['docente'] as Map<String, dynamic>?;
    final materia = json['materia'] as Map<String, dynamic>?;

    return SesionModel(
      id: json['id_sesion'] as int,
      idEstudiante: json['id_estudiante'] as int,
      idDocente: json['id_docente'] as int?,
      idMateria: json['id_materia'] as int,
      temaDescripcion: json['tema_descripcion'] as String?,
      estado: json['estado'] as String? ?? 'Buscando',
      modalidad: json['modalidad'] as String? ?? 'Solo_Chat',
      fechaInicio: json['fecha_inicio'] != null
          ? DateTime.parse(json['fecha_inicio'] as String)
          : null,
      fechaFin: json['fecha_fin'] != null
          ? DateTime.parse(json['fecha_fin'] as String)
          : null,
      costoTotal: (json['costo_total'] as num?)?.toDouble() ?? 0.0,
      docenteNombre: docente != null
          ? '${docente['nombre']} ${docente['apellido']}'
          : null,
      materiaNombre: materia?['nombre'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id_estudiante': idEstudiante,
    'id_docente': idDocente,
    'id_materia': idMateria,
    'tema_descripcion': temaDescripcion,
    'estado': estado,
    'modalidad': modalidad,
    'fecha_inicio': fechaInicio?.toIso8601String(),
    'fecha_fin': fechaFin?.toIso8601String(),
    'costo_total': costoTotal,
  };

  bool get estaActiva => estado == 'Aceptada' || estado == 'En_Curso';

  bool get estaBuscando => estado == 'Buscando';
}
