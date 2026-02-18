import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yachaiya/core/config/supabase_config.dart';
import 'package:yachaiya/data/models/estudiante_model.dart';
import 'package:yachaiya/data/models/docente_model.dart';
import 'package:yachaiya/data/models/nivel_materia_model.dart';
import 'package:yachaiya/data/models/sesion_model.dart';
import 'package:yachaiya/data/models/oferta_docente_model.dart';
import 'package:yachaiya/data/models/mensaje_chat_model.dart';
import 'package:yachaiya/data/models/resena_model.dart';

// ============================================================
// SUPABASE AUTH
// ============================================================

/// Stream del estado de autenticación de Supabase
final authStateProvider = StreamProvider<AuthState>((ref) {
  return SupabaseConfig.client.auth.onAuthStateChange;
});

/// Usuario autenticado actual
final supabaseUserProvider = Provider<User?>((ref) {
  return SupabaseConfig.client.auth.currentUser;
});

// ============================================================
// AUTH MOCK - Rol actual y usuario simulado
// ============================================================

enum UserRole { estudiante, docente, none }

final currentRoleProvider = StateProvider<UserRole>((ref) => UserRole.none);

final mockEstudianteProvider = StateProvider<EstudianteModel?>((ref) => null);
final mockDocenteProvider = StateProvider<DocenteModel?>((ref) => null);

// ============================================================
// NIVELES Y MATERIAS
// ============================================================

final nivelesProvider = FutureProvider<List<NivelModel>>((ref) async {
  final response = await SupabaseConfig.client
      .from('nivel')
      .select()
      .order('id_nivel');
  return (response as List).map((e) => NivelModel.fromJson(e)).toList();
});

final selectedNivelProvider = StateProvider<NivelModel?>((ref) => null);

final materiasByNivelProvider = FutureProvider.family<List<MateriaModel>, int>((
  ref,
  nivelId,
) async {
  final response = await SupabaseConfig.client
      .from('materia')
      .select()
      .eq('id_nivel', nivelId)
      .order('nombre');
  return (response as List).map((e) => MateriaModel.fromJson(e)).toList();
});

final selectedMateriaProvider = StateProvider<MateriaModel?>((ref) => null);

// ============================================================
// SESIÓN ACTUAL
// ============================================================

final currentSesionProvider = StateProvider<SesionModel?>((ref) => null);

final sesionEstadoProvider = StateProvider<String>((ref) => 'idle');
// Posibles: idle, buscando, ofertas, en_sesion, finalizada

// ============================================================
// OFERTAS DE DOCENTES
// ============================================================

final ofertasSesionProvider =
    FutureProvider.family<List<OfertaDocenteModel>, int>((ref, sesionId) async {
      final response = await SupabaseConfig.client
          .from('oferta_docente')
          .select('*, docente(*)')
          .eq('id_sesion', sesionId)
          .eq('estado', 'Pendiente')
          .order('fecha_oferta');
      return (response as List)
          .map((e) => OfertaDocenteModel.fromJson(e))
          .toList();
    });

// ============================================================
// CHAT
// ============================================================

final mensajesChatProvider = StreamProvider.family<List<MensajeChatModel>, int>(
  (ref, sesionId) {
    final role = ref.read(currentRoleProvider);
    final userId = role == UserRole.estudiante
        ? ref.read(mockEstudianteProvider)?.id
        : ref.read(mockDocenteProvider)?.id;

    return SupabaseConfig.client
        .from('mensaje_chat')
        .stream(primaryKey: ['id_mensaje'])
        .eq('id_sesion', sesionId)
        .order('timestamp')
        .map(
          (data) => data
              .map((e) => MensajeChatModel.fromJson(e, currentUserId: userId))
              .toList(),
        );
  },
);

// ============================================================
// HISTORIAL DE SESIONES
// ============================================================

final historialSesionesProvider = FutureProvider<List<SesionModel>>((
  ref,
) async {
  final role = ref.read(currentRoleProvider);
  final query = SupabaseConfig.client
      .from('sesion')
      .select('*, docente(*), materia(*)');

  List<dynamic> response;
  if (role == UserRole.estudiante) {
    final est = ref.read(mockEstudianteProvider);
    if (est == null) return [];
    response = await query
        .eq('id_estudiante', est.id)
        .inFilter('estado', ['Finalizada', 'Cancelada'])
        .order('fecha_fin', ascending: false);
  } else {
    final doc = ref.read(mockDocenteProvider);
    if (doc == null) return [];
    response = await query
        .eq('id_docente', doc.id)
        .inFilter('estado', ['Finalizada', 'Cancelada'])
        .order('fecha_fin', ascending: false);
  }

  return response.map((e) => SesionModel.fromJson(e)).toList();
});

// ============================================================
// DOCENTES - Solicitudes entrantes (vista profesor)
// ============================================================

final solicitudesEntrantes = FutureProvider<List<SesionModel>>((ref) async {
  final doc = ref.read(mockDocenteProvider);
  if (doc == null) return [];

  // Obtener las materias del docente
  final especialidades = await SupabaseConfig.client
      .from('docente_especialidad')
      .select('id_materia')
      .eq('id_docente', doc.id);

  final materiaIds = (especialidades as List)
      .map((e) => e['id_materia'] as int)
      .toList();

  if (materiaIds.isEmpty) return [];

  final response = await SupabaseConfig.client
      .from('sesion')
      .select('*, materia(*)')
      .inFilter('id_materia', materiaIds)
      .eq('estado', 'Buscando')
      .order('fecha_inicio', ascending: false);

  return (response as List).map((e) => SesionModel.fromJson(e)).toList();
});

// ============================================================
// DOCENTES DISPONIBLES (público, sin auth)
// ============================================================

final docentesDisponiblesProvider = FutureProvider<List<DocenteModel>>((
  ref,
) async {
  final response = await SupabaseConfig.client
      .from('docente')
      .select()
      .order('rating_promedio', ascending: false);
  return (response as List).map((e) => DocenteModel.fromJson(e)).toList();
});

// ============================================================
// MATERIAS TODAS (para mostrar catálogo público)
// ============================================================

final todasMateriasProvider = FutureProvider<List<MateriaModel>>((ref) async {
  final response = await SupabaseConfig.client
      .from('materia')
      .select('*, nivel(*)')
      .order('nombre');
  return (response as List).map((e) => MateriaModel.fromJson(e)).toList();
});

// ============================================================
// RESEÑAS DE DOCENTES
// ============================================================

final resenasDocenteProvider = FutureProvider.family<List<ResenaModel>, int>((
  ref,
  docenteId,
) async {
  final response = await SupabaseConfig.client
      .from('resena_docente')
      .select('*, estudiante(*)')
      .eq('id_docente', docenteId)
      .order('fecha_creacion', ascending: false);
  return (response as List).map((e) => ResenaModel.fromJson(e)).toList();
});
