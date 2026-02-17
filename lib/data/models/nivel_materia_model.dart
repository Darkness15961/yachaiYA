class NivelModel {
  final int id;
  final String nombre;

  NivelModel({required this.id, required this.nombre});

  factory NivelModel.fromJson(Map<String, dynamic> json) {
    return NivelModel(
      id: json['id_nivel'] as int,
      nombre: json['nombre'] as String,
    );
  }
}

class MateriaModel {
  final int id;
  final int idNivel;
  final String nombre;
  final String? icono;

  MateriaModel({
    required this.id,
    required this.idNivel,
    required this.nombre,
    this.icono,
  });

  factory MateriaModel.fromJson(Map<String, dynamic> json) {
    return MateriaModel(
      id: json['id_materia'] as int,
      idNivel: json['id_nivel'] as int,
      nombre: json['nombre'] as String,
      icono: json['icono'] as String?,
    );
  }
}
