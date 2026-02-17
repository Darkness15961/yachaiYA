class DocenteModel {
  final int id;
  final String nombre;
  final String apellido;
  final String email;
  final String? dni;
  final String? fotoPerfil;
  final String? biografiaCorta;
  final double saldoActual;
  final String estadoConectividad;
  final double ratingPromedio;
  final double tarifaBaseMinuto;

  DocenteModel({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    this.dni,
    this.fotoPerfil,
    this.biografiaCorta,
    this.saldoActual = 0.0,
    this.estadoConectividad = 'Offline',
    this.ratingPromedio = 5.0,
    this.tarifaBaseMinuto = 0.0,
  });

  factory DocenteModel.fromJson(Map<String, dynamic> json) {
    return DocenteModel(
      id: json['id_docente'] as int,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      email: json['email'] as String,
      dni: json['dni'] as String?,
      fotoPerfil: json['foto_perfil'] as String?,
      biografiaCorta: json['biografia_corta'] as String?,
      saldoActual: (json['saldo_actual'] as num?)?.toDouble() ?? 0.0,
      estadoConectividad: json['estado_conectividad'] as String? ?? 'Offline',
      ratingPromedio: (json['rating_promedio'] as num?)?.toDouble() ?? 5.0,
      tarifaBaseMinuto: (json['tarifa_base_minuto'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'apellido': apellido,
    'email': email,
    'dni': dni,
    'foto_perfil': fotoPerfil,
    'biografia_corta': biografiaCorta,
    'saldo_actual': saldoActual,
    'estado_conectividad': estadoConectividad,
    'rating_promedio': ratingPromedio,
    'tarifa_base_minuto': tarifaBaseMinuto,
  };

  String get nombreCompleto => '$nombre $apellido';
  String get iniciales => '${nombre[0]}${apellido[0]}'.toUpperCase();
  bool get isOnline => estadoConectividad == 'Online';
}
