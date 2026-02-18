class ResenaModel {
  final int id;
  final int idSesion;
  final int idEstudiante;
  final int idDocente;
  final int calificacion; // 1-5 estrellas
  final String? comentario;
  final DateTime fechaCreacion;

  // Relaciones opcionales
  final String? estudianteNombre;
  final String? estudianteFoto;

  ResenaModel({
    required this.id,
    required this.idSesion,
    required this.idEstudiante,
    required this.idDocente,
    required this.calificacion,
    this.comentario,
    required this.fechaCreacion,
    this.estudianteNombre,
    this.estudianteFoto,
  });

  factory ResenaModel.fromJson(Map<String, dynamic> json) {
    final estudiante = json['estudiante'] as Map<String, dynamic>?;

    return ResenaModel(
      id: json['id_resena'] as int,
      idSesion: json['id_sesion'] as int,
      idEstudiante: json['id_estudiante'] as int,
      idDocente: json['id_docente'] as int,
      calificacion: json['calificacion'] as int,
      comentario: json['comentario'] as String?,
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'] as String)
          : DateTime.now(),
      estudianteNombre: estudiante != null
          ? '${estudiante['nombre']} ${estudiante['apellido']}'
          : null,
      estudianteFoto: estudiante?['foto_perfil'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id_sesion': idSesion,
    'id_estudiante': idEstudiante,
    'id_docente': idDocente,
    'calificacion': calificacion,
    'comentario': comentario,
  };
}
