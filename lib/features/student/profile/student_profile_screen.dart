import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:yachaiya/core/theme/app_theme.dart';
import 'package:yachaiya/core/config/supabase_config.dart';
import 'package:yachaiya/core/services/auth_service.dart';
import 'package:yachaiya/data/providers/app_providers.dart';
import 'package:yachaiya/data/models/estudiante_model.dart';

// ── Provider: Stats del estudiante ──
final studentStatsProvider = FutureProvider.family<Map<String, dynamic>, int>((
  ref,
  studentId,
) async {
  // Contar sesiones finalizadas
  final sesiones = await SupabaseConfig.client
      .from('sesion')
      .select('id_sesion')
      .eq('id_estudiante', studentId)
      .eq('estado', 'Finalizada');
  final totalSesiones = (sesiones as List).length;

  // Rating promedio (calificación que el estudiante ha dado)
  final ratings = await SupabaseConfig.client
      .from('sesion')
      .select('calificacion_estudiante')
      .eq('id_estudiante', studentId)
      .eq('estado', 'Finalizada')
      .not('calificacion_estudiante', 'is', null);
  final ratingList = (ratings as List)
      .map((r) => (r['calificacion_estudiante'] as num).toDouble())
      .toList();
  final avgRating = ratingList.isNotEmpty
      ? ratingList.reduce((a, b) => a + b) / ratingList.length
      : 0.0;

  return {'sesiones': totalSesiones, 'rating': avgRating};
});

class StudentProfileScreen extends ConsumerWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final est = ref.watch(mockEstudianteProvider);
    final fotoUrl = est?.fotoPerfil;
    final statsAsync = est != null
        ? ref.watch(studentStatsProvider(est.id))
        : null;

    // Si no está logueado, redirigir a login
    if (est == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.push('/login');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.brand)),
      );
    }

    final totalSesiones = statsAsync?.valueOrNull?['sesiones'] as int? ?? 0;
    final avgRating = statsAsync?.valueOrNull?['rating'] as double? ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
      child: Column(
        children: [
          // ── Profile Header ──
          Container(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.brand, AppColors.brand2],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brand.withValues(alpha: 0.3),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Avatar con botón de editar foto
                    Stack(
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: fotoUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: fotoUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(
                                      color: Colors.white24,
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 36,
                                      ),
                                    ),
                                    errorWidget: (_, __, ___) => Container(
                                      color: Colors.white24,
                                      child: Center(
                                        child: Text(
                                          est.iniciales,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 30,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: Colors.white24,
                                    child: Center(
                                      child: Text(
                                        est.iniciales,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 30,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      est.nombreCompleto,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      est.email,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                    if (est.celular != null && est.celular!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        est.celular!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.95, 0.95)),

          const SizedBox(height: 20),

          // ── Stats Row ──
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Saldo',
                  value: 'S/ ${est.saldoActual.toStringAsFixed(2)}',
                  color: AppColors.brand,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: Icons.school_rounded,
                  label: 'Sesiones',
                  value: '$totalSesiones',
                  color: AppColors.ok,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: Icons.star_rounded,
                  label: 'Calificación',
                  value: avgRating > 0 ? avgRating.toStringAsFixed(1) : 'N/A',
                  color: AppColors.warn,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 20),

          // ── Saldo + Recargar ──
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.line),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saldo Disponible',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'S/ ${est.saldoActual.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppColors.brand,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => _showRecargarDialog(context, ref, est),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.brand.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Recargar',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 16),

          // ── Options Menu ──
          _OptionTile(
            icon: Icons.person_rounded,
            label: 'Editar Perfil',
            subtitle: 'Nombre, teléfono, DNI',
            color: const Color(0xFF6366F1),
            onTap: () => _showEditProfileSheet(context, ref, est),
          ).animate().fadeIn(delay: 350.ms),

          _OptionTile(
            icon: Icons.notifications_rounded,
            label: 'Notificaciones',
            subtitle: 'Gestiona tus alertas',
            color: const Color(0xFFF59E0B),
            onTap: () => _showNotificacionesDialog(context),
          ).animate().fadeIn(delay: 400.ms),

          _OptionTile(
            icon: Icons.help_outline_rounded,
            label: 'Ayuda y Soporte',
            subtitle: 'Preguntas frecuentes',
            color: const Color(0xFF06B6D4),
            onTap: () => _showAyudaSheet(context),
          ).animate().fadeIn(delay: 450.ms),

          _OptionTile(
            icon: Icons.info_outline_rounded,
            label: 'Acerca de YachaiYA',
            subtitle: 'Versión 1.0.0',
            color: const Color(0xFF8B5CF6),
            onTap: () => _showAcercaDeDialog(context),
          ).animate().fadeIn(delay: 480.ms),

          // ── ¿Eres docente? / Cambiar a Vista Docente ──
          if (ref.watch(mockDocenteProvider) != null)
            _OptionTile(
              icon: Icons.cast_for_education_rounded,
              label: 'Cambiar a Vista Docente',
              subtitle: 'Accede a tu panel de profesor',
              color: const Color(0xFF10B981),
              onTap: () {
                ref.read(currentRoleProvider.notifier).state = UserRole.docente;
                context.go('/teacher');
              },
            ).animate().fadeIn(delay: 500.ms)
          else
            _OptionTile(
              icon: Icons.school_rounded,
              label: '¿Eres docente?',
              subtitle: 'Postula para enseñar en YachaiYA',
              color: const Color(0xFF10B981),
              onTap: () => _showPostulacionSheet(context, ref, est),
            ).animate().fadeIn(delay: 500.ms),

          _OptionTile(
            icon: Icons.logout_rounded,
            label: 'Cerrar Sesión',
            subtitle: 'Salir de tu cuenta',
            color: AppColors.danger,
            isDestructive: true,
            onTap: () => _showLogoutConfirm(context, ref),
          ).animate().fadeIn(delay: 550.ms),
        ],
      ),
    );
  }

  // ── POSTULACIÓN DOCENTE ──
  void _showPostulacionSheet(
    BuildContext context,
    WidgetRef ref,
    EstudianteModel est,
  ) {
    // Controladores
    final bioCtrl = TextEditingController();
    final otroEspecialidadCtrl = TextEditingController();

    // Estado local del modal (para dropdown)
    String? selectedEspecialidad;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Consumer(
        builder: (context, ref, child) {
          final materiasAsync = ref.watch(todasMateriasProvider);

          return StatefulBuilder(
            builder: (ctx, setModalState) {
              return Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.line,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF10B981,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.school_rounded,
                              color: Color(0xFF10B981),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Postula como Docente',
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                Text(
                                  'Comparte tu conocimiento y genera ingresos',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Info box
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(
                              0xFF10B981,
                            ).withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: Color(0xFF10B981),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Tu postulación será revisada por nuestro equipo. Te notificaremos cuando sea aprobada.',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF166534),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Especialidad (Dropdown)
                      Text(
                        'Especialidad Principal',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      materiasAsync.when(
                        data: (materias) {
                          // Extraer nombres únicos y ordenarlos
                          final nombresMaterias =
                              materias.map((m) => m.nombre).toSet().toList()
                                ..sort();

                          // Agregar opción 'Otro' si no existe
                          if (!nombresMaterias.contains('Otro')) {
                            nombresMaterias.add('Otro');
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButtonFormField<String>(
                                value: selectedEspecialidad,
                                items: nombresMaterias.map((m) {
                                  return DropdownMenuItem(
                                    value: m,
                                    child: Text(
                                      m,
                                      style: GoogleFonts.inter(fontSize: 14),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setModalState(() {
                                    selectedEspecialidad = val;
                                  });
                                },
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  hintText: 'Selecciona una especialidad',
                                  hintStyle: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: AppColors.muted,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.bg,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: AppColors.line.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: AppColors.brand,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.textDark,
                                ),
                                dropdownColor: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              // Si eligió 'Otro', mostrar campo de texto adicional
                              if (selectedEspecialidad == 'Otro') ...[
                                const SizedBox(height: 12),
                                TextField(
                                  controller: otroEspecialidadCtrl,
                                  decoration: InputDecoration(
                                    hintText: 'Especifica tu especialidad...',
                                    hintStyle: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: AppColors.muted,
                                    ),
                                    filled: true,
                                    fillColor: AppColors.bg,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: AppColors.brand,
                                        width: 1.5,
                                      ),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.edit_note_rounded,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                        loading: () => Container(
                          height: 56,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.bg,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.brand,
                              ),
                            ),
                          ),
                        ),
                        error: (_, __) => Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            'Error al cargar especialidades',
                            style: GoogleFonts.inter(
                              color: AppColors.danger,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Biografía
                      Text(
                        'Sobre ti',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: bioCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Cuéntanos tu experiencia docente...',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.muted,
                          ),
                          filled: true,
                          fillColor: AppColors.bg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: AppColors.line.withValues(alpha: 0.5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: AppColors.brand,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Botón enviar
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF059669)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF10B981,
                                ).withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              // Validaciones
                              if (selectedEspecialidad == null) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Selecciona tu especialidad',
                                    ),
                                    backgroundColor: AppColors.warn,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                                return;
                              }

                              String especialidadFinal = selectedEspecialidad!;
                              if (selectedEspecialidad == 'Otro') {
                                if (otroEspecialidadCtrl.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'Especifique su otra especialidad',
                                      ),
                                      backgroundColor: AppColors.warn,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                especialidadFinal = otroEspecialidadCtrl.text
                                    .trim();
                              }

                              try {
                                await SupabaseConfig.client.from('docente').insert({
                                  'nombre': est.nombre,
                                  'apellido': est.apellido,
                                  'email': est.email,
                                  'password_hash': 'google_oauth_postulacion',
                                  'foto_perfil': est.fotoPerfil,
                                  'saldo_actual': 0.0,
                                  'estado_conectividad': 'Offline',
                                  'rating_promedio': 5.0,
                                  'tarifa_base_minuto': 0.0,
                                  'biografia_corta': especialidadFinal,
                                  // TODO: Agregar columna 'biografia' o 'descripcion' en tabla docente
                                }); // Consider adding 'especialidad': especialidadFinal if the DB supports it

                                if (ctx.mounted) {
                                  Navigator.pop(ctx);
                                  showDialog(
                                    context: context,
                                    builder: (dCtx) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFF10B981,
                                              ).withValues(alpha: 0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.check_circle_rounded,
                                              color: Color(0xFF10B981),
                                              size: 48,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            '¡Postulación Enviada!',
                                            style: GoogleFonts.inter(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Nuestro equipo revisará tu perfil y te notificará cuando sea aprobado. ¡Gracias por querer enseñar!',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              color: AppColors.muted,
                                              height: 1.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(dCtx),
                                          child: Text(
                                            'Entendido',
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF10B981),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (ctx.mounted) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $e'),
                                      backgroundColor: AppColors.danger,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.send_rounded, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Enviar Postulación',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ── EDITAR PERFIL ──
  void _showEditProfileSheet(
    BuildContext context,
    WidgetRef ref,
    EstudianteModel est,
  ) {
    final nombreCtrl = TextEditingController(text: est.nombre);
    final apellidoCtrl = TextEditingController(text: est.apellido);
    final celularCtrl = TextEditingController(text: est.celular ?? '');
    final dniCtrl = TextEditingController(text: est.dni ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.line,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Editar Perfil',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField('Nombre', nombreCtrl, Icons.person_rounded),
                  const SizedBox(height: 14),
                  _buildTextField(
                    'Apellido',
                    apellidoCtrl,
                    Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    'Celular',
                    celularCtrl,
                    Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    'DNI',
                    dniCtrl,
                    Icons.badge_rounded,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brand.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            await SupabaseConfig.client
                                .from('estudiante')
                                .update({
                                  'nombre': nombreCtrl.text.trim(),
                                  'apellido': apellidoCtrl.text.trim(),
                                  'celular': celularCtrl.text.trim().isEmpty
                                      ? null
                                      : celularCtrl.text.trim(),
                                  'dni': dniCtrl.text.trim().isEmpty
                                      ? null
                                      : dniCtrl.text.trim(),
                                })
                                .eq('id_estudiante', est.id);

                            // Recargar datos del estudiante
                            final updated = await SupabaseConfig.client
                                .from('estudiante')
                                .select()
                                .eq('id_estudiante', est.id)
                                .single();
                            ref.read(mockEstudianteProvider.notifier).state =
                                EstudianteModel.fromJson(updated);

                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                  content: const Text('Perfil actualizado ✓'),
                                  backgroundColor: AppColors.ok,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: AppColors.danger,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Guardar Cambios',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: AppColors.muted.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: AppColors.bg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.line.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.brand, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ── RECARGAR SALDO ──
  void _showRecargarDialog(
    BuildContext context,
    WidgetRef ref,
    EstudianteModel est,
  ) {
    final montos = [10.0, 20.0, 50.0, 100.0];
    double? selectedMonto;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          bool processing = false;

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.line,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Recargar Saldo',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Saldo actual: S/ ${est.saldoActual.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Selecciona el monto:',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: montos.map((m) {
                    final isSelected = selectedMonto == m;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setModalState(() => selectedMonto = m),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.brand : AppColors.bg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.brand
                                  : AppColors.line,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'S/ ${m.toInt()}',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: selectedMonto != null
                          ? AppColors.primaryGradient
                          : null,
                      color: selectedMonto == null
                          ? AppColors.muted.withValues(alpha: 0.3)
                          : null,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ElevatedButton(
                      onPressed: selectedMonto == null || processing
                          ? null
                          : () async {
                              setModalState(() => processing = true);
                              try {
                                final nuevoSaldo =
                                    est.saldoActual + selectedMonto!;
                                await SupabaseConfig.client
                                    .from('estudiante')
                                    .update({'saldo_actual': nuevoSaldo})
                                    .eq('id_estudiante', est.id);

                                final updated = await SupabaseConfig.client
                                    .from('estudiante')
                                    .select()
                                    .eq('id_estudiante', est.id)
                                    .single();
                                ref
                                    .read(mockEstudianteProvider.notifier)
                                    .state = EstudianteModel.fromJson(
                                  updated,
                                );

                                if (ctx.mounted) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Recarga de S/ ${selectedMonto!.toInt()} exitosa ✓',
                                      ),
                                      backgroundColor: AppColors.ok,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                setModalState(() => processing = false);
                                if (ctx.mounted) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $e'),
                                      backgroundColor: AppColors.danger,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.transparent,
                        disabledForegroundColor: AppColors.muted,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: processing
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              selectedMonto != null
                                  ? 'Recargar S/ ${selectedMonto!.toInt()}'
                                  : 'Selecciona un monto',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── NOTIFICACIONES ──
  void _showNotificacionesDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.notifications_rounded,
                    color: Color(0xFFF59E0B),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  'Notificaciones',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _NotifToggle(label: 'Nuevas ofertas de profesores', value: true),
            _NotifToggle(label: 'Sesión aceptada', value: true),
            _NotifToggle(label: 'Mensajes de chat', value: true),
            _NotifToggle(label: 'Promociones y novedades', value: false),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // ── AYUDA ──
  void _showAyudaSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.7,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Ayuda y Soporte',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 20),
              _FaqItem(
                question: '¿Cómo funciona YachaiYA?',
                answer:
                    'YachaiYA te conecta con profesores expertos de forma instantánea. Crea una consulta, elige tu tema y un profesor disponible te ayudará.',
              ),
              _FaqItem(
                question: '¿Cómo recargo mi saldo?',
                answer:
                    'Ve a tu perfil y presiona el botón "Recargar". Selecciona el monto deseado para añadir fondos a tu cuenta.',
              ),
              _FaqItem(
                question: '¿Cómo cancelo una sesión?',
                answer:
                    'Mientras la sesión esté en estado "Buscando", puedes cancelarla desde la pantalla de búsqueda sin costo alguno.',
              ),
              _FaqItem(
                question: '¿Cómo contacto a soporte?',
                answer:
                    'Escríbenos a soporte@yachaiya.com o a nuestro WhatsApp. Respondemos en máximo 24 horas.',
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.brand.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.brand.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.email_rounded,
                      color: AppColors.brand,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '¿Necesitas más ayuda?',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'soporte@yachaiya.com',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.brand,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── ACERCA DE ──
  void _showAcercaDeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: AppColors.primaryGradient,
              ),
              child: const Center(
                child: Text(
                  'Y',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'YachaiYA',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Versión 1.0.0',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.muted),
            ),
            const SizedBox(height: 12),
            Text(
              'Asesoría Académica al Instante.\nConecta con expertos cuando más lo necesitas.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.muted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '© 2026 YachaiYA. Todos los derechos reservados.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.muted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cerrar',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: AppColors.brand,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── CONFIRMAR LOGOUT ──
  void _showLogoutConfirm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          'Cerrar Sesión',
          style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        content: Text(
          '¿Estás seguro de que quieres cerrar sesión?',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService.signOut();
              ref.read(currentRoleProvider.notifier).state = UserRole.none;
              ref.read(mockEstudianteProvider.notifier).state = null;
              ref.read(mockDocenteProvider.notifier).state = null;
              if (context.mounted) context.go('/');
            },
            child: Text(
              'Cerrar Sesión',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: AppColors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Card ──
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

// ── Option Tile ──
class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isDestructive;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isDestructive ? AppColors.danger : AppColors.textDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: isDestructive
                ? AppColors.danger.withValues(alpha: 0.6)
                : AppColors.muted,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: AppColors.muted.withValues(alpha: 0.5),
          size: 20,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

// ── Notification Toggle ──
class _NotifToggle extends StatefulWidget {
  final String label;
  final bool value;

  const _NotifToggle({required this.label, required this.value});

  @override
  State<_NotifToggle> createState() => _NotifToggleState();
}

class _NotifToggleState extends State<_NotifToggle> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              widget.label,
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark),
            ),
          ),
          Switch(
            value: _value,
            onChanged: (v) => setState(() => _value = v),
            activeThumbColor: AppColors.brand,
          ),
        ],
      ),
    );
  }
}

// ── FAQ Item ──
class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.muted,
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 10),
                Text(
                  widget.answer,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.muted,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
