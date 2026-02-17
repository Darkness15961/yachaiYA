class MensajeChatModel {
  final int id;
  final int idSesion;
  final int emisorId;
  final String tipo;
  final String contenido;
  final DateTime timestamp;
  final bool esMio;

  MensajeChatModel({
    required this.id,
    required this.idSesion,
    required this.emisorId,
    this.tipo = 'Texto',
    required this.contenido,
    required this.timestamp,
    this.esMio = false,
  });

  factory MensajeChatModel.fromJson(
    Map<String, dynamic> json, {
    int? currentUserId,
  }) {
    return MensajeChatModel(
      id: json['id_mensaje'] as int,
      idSesion: json['id_sesion'] as int,
      emisorId: json['emisor_id'] as int,
      tipo: json['tipo'] as String? ?? 'Texto',
      contenido: json['contenido'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      esMio: currentUserId != null && json['emisor_id'] == currentUserId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id_sesion': idSesion,
    'emisor_id': emisorId,
    'tipo': tipo,
    'contenido': contenido,
  };
}
