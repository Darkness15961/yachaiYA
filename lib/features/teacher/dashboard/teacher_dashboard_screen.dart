import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:yachaiya/core/theme/app_theme.dart';
import 'package:yachaiya/core/config/supabase_config.dart';
import 'package:yachaiya/data/providers/app_providers.dart';
import 'package:yachaiya/data/models/sesion_model.dart';

// ── Provider: Teacher stats ──
final teacherStatsProvider = FutureProvider.family<Map<String, dynamic>, int>((
  ref,
  docenteId,
) async {
  final sesiones = await SupabaseConfig.client
      .from('sesion')
      .select('id_sesion')
      .eq('id_docente', docenteId)
      .eq('estado', 'Finalizada');
  final totalSesiones = (sesiones as List).length;

  final ratings = await SupabaseConfig.client
      .from('sesion')
      .select('calificacion_estudiante')
      .eq('id_docente', docenteId)
      .eq('estado', 'Finalizada')
      .not('calificacion_estudiante', 'is', null);
  final ratingList = (ratings as List)
      .map((r) => (r['calificacion_estudiante'] as num).toDouble())
      .toList();
  final avgRating = ratingList.isNotEmpty
      ? ratingList.reduce((a, b) => a + b) / ratingList.length
      : 0.0;

  // Ingresos totales
  final ingresos = await SupabaseConfig.client
      .from('sesion')
      .select('costo_total')
      .eq('id_docente', docenteId)
      .eq('estado', 'Finalizada');
  final totalIngresos = (ingresos as List).fold<double>(
    0,
    (sum, r) => sum + ((r['costo_total'] as num?)?.toDouble() ?? 0),
  );

  return {
    'sesiones': totalSesiones,
    'rating': avgRating,
    'ingresos': totalIngresos,
  };
});

class TeacherDashboardScreen extends ConsumerStatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  ConsumerState<TeacherDashboardScreen> createState() =>
      _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState
    extends ConsumerState<TeacherDashboardScreen> {
  String _estado = 'Online';

  @override
  void initState() {
    super.initState();
    final doc = ref.read(mockDocenteProvider);
    if (doc != null) {
      _estado = doc.estadoConectividad;
    }
  }

  void _updateEstado(String nuevoEstado) async {
    setState(() => _estado = nuevoEstado);
    final doc = ref.read(mockDocenteProvider);
    if (doc != null) {
      try {
        await SupabaseConfig.client
            .from('docente')
            .update({'estado_conectividad': nuevoEstado})
            .eq('id_docente', doc.id);
      } catch (_) {}
    }
  }

  void _showOfertaDialog(SesionModel solicitud) {
    final precioController = TextEditingController(text: '20');
    final duracionController = TextEditingController(text: '40');
    final mensajeController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.local_offer_rounded,
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
                          'Enviar Oferta',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${solicitud.temaDescripcion ?? "Sin tema"} · ${solicitud.materiaNombre ?? "Materia"}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Precio y Duración en una fila
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Precio (S/)',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: precioController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            prefixText: 'S/ ',
                            hintText: '20',
                            filled: true,
                            fillColor: AppColors.bg,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color(0xFF10B981),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Duración (min)',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: duracionController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            suffixText: 'min',
                            hintText: '40',
                            filled: true,
                            fillColor: AppColors.bg,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color(0xFF10B981),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Mensaje (opcional)',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: mensajeController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Ej: Tengo 5 años de experiencia...',
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
                      color: Color(0xFF10B981),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
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
                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      final doc = ref.read(mockDocenteProvider);
                      if (doc == null) return;
                      try {
                        await SupabaseConfig.client
                            .from('oferta_docente')
                            .insert({
                              'id_sesion': solicitud.id,
                              'id_docente': doc.id,
                              'precio_ofertado':
                                  double.tryParse(precioController.text) ??
                                  20.0,
                              'duracion_minutos':
                                  int.tryParse(duracionController.text) ?? 40,
                              'mensaje': mensajeController.text.isNotEmpty
                                  ? mensajeController.text
                                  : null,
                              'estado': 'Pendiente',
                            });
                      } catch (_) {}
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('¡Oferta enviada! ✓'),
                            backgroundColor: const Color(0xFF10B981),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
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
                          'Enviar Oferta',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final docente = ref.watch(mockDocenteProvider);
    final solicitudesAsync = ref.watch(solicitudesEntrantes);
    final statsAsync = docente != null
        ? ref.watch(teacherStatsProvider(docente.id))
        : null;
    final fotoUrl = docente?.fotoPerfil;

    final totalSesiones = statsAsync?.valueOrNull?['sesiones'] as int? ?? 0;
    final avgRating = statsAsync?.valueOrNull?['rating'] as double? ?? 0.0;
    final totalIngresos =
        statsAsync?.valueOrNull?['ingresos'] as double? ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header con foto y saludo ──
          Container(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.3),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 2.5,
                            ),
                          ),
                          child: ClipOval(
                            child: fotoUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: fotoUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(
                                      color: Colors.white24,
                                      child: Center(
                                        child: Text(
                                          docente?.iniciales ?? '?',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (_, __, ___) => Container(
                                      color: Colors.white24,
                                      child: Center(
                                        child: Text(
                                          docente?.iniciales ?? '?',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
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
                                        docente?.iniciales ?? '?',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '¡Hola, ${docente?.nombre ?? "Profesor"}! 👋',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                docente?.biografiaCorta ??
                                    'Bienvenido a tu panel',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.75),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'S/ ${docente?.saldoActual.toStringAsFixed(2) ?? "0.00"}',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Estado pills
                    Row(
                      children: [
                        _EstadoPill(
                          'Online',
                          _estado,
                          const Color(0xFF10B981),
                          () => _updateEstado('Online'),
                        ),
                        const SizedBox(width: 8),
                        _EstadoPill(
                          'Offline',
                          _estado,
                          AppColors.muted,
                          () => _updateEstado('Offline'),
                        ),
                        const SizedBox(width: 8),
                        _EstadoPill(
                          'Ocupado',
                          _estado,
                          AppColors.warn,
                          () => _updateEstado('Ocupado'),
                        ),
                      ],
                    ),
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
                  icon: Icons.school_rounded,
                  label: 'Sesiones',
                  value: '$totalSesiones',
                  color: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: Icons.star_rounded,
                  label: 'Rating',
                  value: avgRating > 0 ? avgRating.toStringAsFixed(1) : 'N/A',
                  color: AppColors.warn,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: Icons.trending_up_rounded,
                  label: 'Ingresos',
                  value: 'S/ ${totalIngresos.toStringAsFixed(0)}',
                  color: AppColors.brand,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 24),

          // ── Solicitudes ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Solicitudes Entrantes',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              solicitudesAsync.when(
                data: (s) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: s.isNotEmpty
                        ? const Color(0xFF10B981).withValues(alpha: 0.1)
                        : AppColors.muted.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${s.length} ${s.length == 1 ? 'nueva' : 'nuevas'}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: s.isNotEmpty
                          ? const Color(0xFF10B981)
                          : AppColors.muted,
                    ),
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          solicitudesAsync.when(
            data: (solicitudes) {
              if (solicitudes.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.muted.withValues(alpha: 0.06),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.inbox_rounded,
                          size: 40,
                          color: AppColors.muted.withValues(alpha: 0.3),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Sin solicitudes por ahora',
                        style: GoogleFonts.inter(
                          color: AppColors.muted,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mantente Online para recibir solicitudes',
                        style: GoogleFonts.inter(
                          color: AppColors.muted.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms);
              }
              return Column(
                children: solicitudes.asMap().entries.map((entry) {
                  final i = entry.key;
                  final sol = entry.value;
                  return _SolicitudCard(
                    sesion: sol,
                    onEnviarOferta: () => _showOfertaDialog(sol),
                    onAcceder: () {
                      ref.read(sesionEstadoProvider.notifier).state =
                          'en_sesion';
                      ref.read(currentSesionProvider.notifier).state = sol;
                      context.push('/teacher/session');
                    },
                  ).animate().fadeIn(
                    delay: Duration(milliseconds: 300 + i * 100),
                    duration: 300.ms,
                  );
                }).toList(),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 30),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF10B981)),
              ),
            ),
            error: (_, __) => Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    size: 40,
                    color: AppColors.danger.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Error al cargar solicitudes',
                    style: GoogleFonts.inter(
                      color: AppColors.danger,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Estado Pill ──
class _EstadoPill extends StatelessWidget {
  final String label;
  final String currentState;
  final Color color;
  final VoidCallback onTap;
  const _EstadoPill(this.label, this.currentState, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    final isActive = label == currentState;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? color : Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isActive ? color : Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
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

// ── Solicitud Card ──
class _SolicitudCard extends StatelessWidget {
  final SesionModel sesion;
  final VoidCallback onEnviarOferta;
  final VoidCallback onAcceder;
  const _SolicitudCard({
    required this.sesion,
    required this.onEnviarOferta,
    required this.onAcceder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Center(
                  child: Icon(
                    Icons.person_rounded,
                    color: Color(0xFF10B981),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estudiante #${sesion.idEstudiante}',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    if (sesion.fechaInicio != null)
                      Text(
                        'hace ${DateTime.now().difference(sesion.fechaInicio!).inMinutes} min',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                  ],
                ),
              ),
              if (sesion.materiaNombre != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warn.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    sesion.materiaNombre!,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.warn,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            sesion.temaDescripcion ?? 'Sin tema',
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          // Badges de duración y tipo
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.brand.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_rounded, size: 13, color: AppColors.brand),
                    const SizedBox(width: 4),
                    Text(
                      sesion.duracionLabel,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brand,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: sesion.esPrivada
                      ? AppColors.warn.withValues(alpha: 0.08)
                      : const Color(0xFF10B981).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      sesion.esPrivada
                          ? Icons.lock_rounded
                          : Icons.public_rounded,
                      size: 13,
                      color: sesion.esPrivada
                          ? AppColors.warn
                          : const Color(0xFF10B981),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      sesion.esPrivada ? 'Privada' : 'Pública',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: sesion.esPrivada
                            ? AppColors.warn
                            : const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: onEnviarOferta,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Enviar Oferta',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
