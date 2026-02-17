import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:yachaiya/core/config/supabase_config.dart';
import 'package:yachaiya/data/models/estudiante_model.dart';
import 'package:yachaiya/data/models/docente_model.dart';

class AuthService {
  static SupabaseClient get _client => SupabaseConfig.client;

  /// Google Client ID (web) desde .env
  static String get _webClientId => dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';

  /// Login con Google nativo (popup dentro de la app)
  static Future<AuthResponse> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn(serverClientId: _webClientId);

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Login cancelado por el usuario');
    }

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    if (idToken == null) {
      throw Exception('No se pudo obtener el ID Token de Google');
    }

    // Autenticar con Supabase usando el token de Google
    final response = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    return response;
  }

  /// Cerrar sesión (Google + Supabase)
  static Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    await _client.auth.signOut();
  }

  /// Usuario actual de Supabase Auth
  static User? get currentUser => _client.auth.currentUser;

  /// Stream de cambios de auth
  static Stream<AuthState> get onAuthStateChange =>
      _client.auth.onAuthStateChange;

  /// Buscar estudiante por email, si no existe lo crea
  static Future<EstudianteModel> findOrCreateEstudiante() async {
    final user = currentUser;
    if (user == null) throw Exception('No hay usuario autenticado');

    final email = user.email!;
    final metadata = user.userMetadata;
    final fullName =
        metadata?['full_name'] as String? ??
        metadata?['name'] as String? ??
        email.split('@').first;

    final parts = fullName.split(' ');
    final nombre = parts.first;
    final apellido = parts.length > 1 ? parts.sublist(1).join(' ') : '.';
    final fotoPerfil =
        metadata?['avatar_url'] as String? ?? metadata?['picture'] as String?;

    // Buscar si ya existe por email
    final existing = await _client
        .from('estudiante')
        .select()
        .eq('email', email)
        .maybeSingle();

    if (existing != null) {
      return EstudianteModel.fromJson(existing);
    }

    // Crear nuevo — con manejo de conflicto de secuencia
    try {
      final inserted = await _client
          .from('estudiante')
          .insert({
            'nombre': nombre,
            'apellido': apellido,
            'email': email,
            'password_hash': 'google_oauth_${user.id}',
            'foto_perfil': fotoPerfil,
            'saldo_actual': 50.0,
          })
          .select()
          .single();

      return EstudianteModel.fromJson(inserted);
    } on PostgrestException {
      // Si falla por conflicto de secuencia, buscar el último ID y reintentar
      final maxIdResult = await _client
          .from('estudiante')
          .select('id_estudiante')
          .order('id_estudiante', ascending: false)
          .limit(1)
          .maybeSingle();

      final nextId = (maxIdResult?['id_estudiante'] as int? ?? 0) + 1;

      final inserted = await _client
          .from('estudiante')
          .insert({
            'id_estudiante': nextId,
            'nombre': nombre,
            'apellido': apellido,
            'email': email,
            'password_hash': 'google_oauth_${user.id}',
            'foto_perfil': fotoPerfil,
            'saldo_actual': 50.0,
          })
          .select()
          .single();

      return EstudianteModel.fromJson(inserted);
    }
  }

  /// Buscar docente por email, si no existe lo crea
  static Future<DocenteModel> findOrCreateDocente() async {
    final user = currentUser;
    if (user == null) throw Exception('No hay usuario autenticado');

    final email = user.email!;
    final metadata = user.userMetadata;
    final fullName =
        metadata?['full_name'] as String? ??
        metadata?['name'] as String? ??
        email.split('@').first;

    final parts = fullName.split(' ');
    final nombre = parts.first;
    final apellido = parts.length > 1 ? parts.sublist(1).join(' ') : '.';
    final fotoPerfil =
        metadata?['avatar_url'] as String? ?? metadata?['picture'] as String?;

    final existing = await _client
        .from('docente')
        .select()
        .eq('email', email)
        .maybeSingle();

    if (existing != null) {
      return DocenteModel.fromJson(existing);
    }

    try {
      final inserted = await _client
          .from('docente')
          .insert({
            'nombre': nombre,
            'apellido': apellido,
            'email': email,
            'password_hash': 'google_oauth_${user.id}',
            'foto_perfil': fotoPerfil,
            'saldo_actual': 0.0,
            'estado_conectividad': 'Online',
            'rating_promedio': 5.0,
            'tarifa_base_minuto': 1.0,
            'biografia_corta': 'Nuevo docente en YachaiYA',
          })
          .select()
          .single();

      return DocenteModel.fromJson(inserted);
    } on PostgrestException {
      final maxIdResult = await _client
          .from('docente')
          .select('id_docente')
          .order('id_docente', ascending: false)
          .limit(1)
          .maybeSingle();

      final nextId = (maxIdResult?['id_docente'] as int? ?? 0) + 1;

      final inserted = await _client
          .from('docente')
          .insert({
            'id_docente': nextId,
            'nombre': nombre,
            'apellido': apellido,
            'email': email,
            'password_hash': 'google_oauth_${user.id}',
            'foto_perfil': fotoPerfil,
            'saldo_actual': 0.0,
            'estado_conectividad': 'Online',
            'rating_promedio': 5.0,
            'tarifa_base_minuto': 1.0,
            'biografia_corta': 'Nuevo docente en YachaiYA',
          })
          .select()
          .single();

      return DocenteModel.fromJson(inserted);
    }
  }
}
