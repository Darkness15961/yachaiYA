import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:yachaiya/core/theme/app_theme.dart';
import 'package:yachaiya/core/config/supabase_config.dart';
import 'package:yachaiya/data/providers/app_providers.dart';
import 'package:yachaiya/data/models/sesion_model.dart';

class TeacherDashboardScreen extends ConsumerStatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  ConsumerState<TeacherDashboardScreen> createState() =>
      _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState
    extends ConsumerState<TeacherDashboardScreen> {
  String _estado = 'Online';

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
    final mensajeController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
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
            const SizedBox(height: 18),
            Text(
              'Enviar Oferta',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${solicitud.temaDescripcion ?? "Sin tema"} · ${solicitud.materiaNombre ?? "Materia"}',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.muted),
            ),
            const SizedBox(height: 18),
            Text(
              'Precio (S/)',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.muted),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: precioController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixText: 'S/ ',
                hintText: '20',
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Mensaje (opcional)',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.muted),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: mensajeController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Ej: Tengo 5 años de experiencia...',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.okGradient,
                  borderRadius: BorderRadius.circular(999),
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
                                double.tryParse(precioController.text) ?? 20.0,
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
                          content: const Text('¡Oferta enviada a Supabase!'),
                          backgroundColor: AppColors.ok,
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
                  ),
                  child: Text(
                    'Enviar Oferta',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final docente = ref.watch(mockDocenteProvider);
    final solicitudesAsync = ref.watch(solicitudesEntrantes);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Saludo + Estado
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.ok.withValues(alpha: 0.08),
                  AppColors.brand2.withValues(alpha: 0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.ok.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¡Hola, ${docente?.nombre ?? "Profesor"}! 👋',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Panel de control docente',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.muted,
                            ),
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.account_balance_wallet_rounded,
                            size: 16,
                            color: AppColors.ok,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'S/ ${docente?.saldoActual.toStringAsFixed(2) ?? "0.00"}',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _EstadoPill(
                      'Online',
                      _estado,
                      AppColors.ok,
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
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 20),

          // Solicitudes reales
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
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brand.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${s.length} nuevas',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brand,
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
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_rounded,
                        size: 48,
                        color: AppColors.muted.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Sin solicitudes por ahora',
                        style: GoogleFonts.inter(
                          color: AppColors.muted,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
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
                    delay: Duration(milliseconds: 150 + i * 100),
                    duration: 300.ms,
                  );
                }).toList(),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 30),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => Container(
              padding: const EdgeInsets.all(40),
              child: Text(
                'Error al cargar solicitudes',
                style: GoogleFonts.inter(color: AppColors.danger),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: isActive ? color : AppColors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? Colors.white : color,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
        boxShadow: const [appShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.brand.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.person_rounded,
                    color: AppColors.brand,
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
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warn.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
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
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.okGradient,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: ElevatedButton(
                    onPressed: onEnviarOferta,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Enviar Oferta',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
