class EstudianteModel {
  final int id;
  final String nombre;
  final String apellido;
  final String email;
  final String? dni;
  final String? celular;
  final String? fotoPerfil;
  final double saldoActual;
  final DateTime? fechaRegistro;

  EstudianteModel({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    this.dni,
    this.celular,
    this.fotoPerfil,
    this.saldoActual = 0.0,
    this.fechaRegistro,
  });

  factory EstudianteModel.fromJson(Map<String, dynamic> json) {
    return EstudianteModel(
      id: json['id_estudiante'] as int,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      email: json['email'] as String,
      dni: json['dni'] as String?,
      celular: json['celular'] as String?,
      fotoPerfil: json['foto_perfil'] as String?,
      saldoActual: (json['saldo_actual'] as num?)?.toDouble() ?? 0.0,
      fechaRegistro: json['fecha_registro'] != null
          ? DateTime.parse(json['fecha_registro'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'apellido': apellido,
    'email': email,
    'dni': dni,
    'celular': celular,
    'foto_perfil': fotoPerfil,
    'saldo_actual': saldoActual,
  };

  String get nombreCompleto => '$nombre $apellido';
  String get iniciales => '${nombre[0]}${apellido[0]}'.toUpperCase();
}
