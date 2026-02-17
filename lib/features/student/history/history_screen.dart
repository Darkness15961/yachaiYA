import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:yachaiya/core/theme/app_theme.dart';
import 'package:yachaiya/data/providers/app_providers.dart';
import 'package:yachaiya/data/models/sesion_model.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historialAsync = ref.watch(historialSesionesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Historial de Sesiones',
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          historialAsync.when(
            data: (sesiones) {
              if (sesiones.isEmpty) {
                return _buildEmptyState();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${sesiones.length} sesiones completadas',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...sesiones.asMap().entries.map((entry) {
                    final i = entry.key;
                    final s = entry.value;
                    return _HistoryCard(sesion: s)
                        .animate()
                        .fadeIn(
                          delay: Duration(milliseconds: i * 100),
                          duration: 300.ms,
                        )
                        .slideY(begin: 0.1);
                  }),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => _buildFallbackHistory(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.history_rounded,
              size: 48,
              color: AppColors.muted.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'Aún no tienes sesiones',
              style: GoogleFonts.inter(color: AppColors.muted, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              '¡Haz tu primera consulta!',
              style: GoogleFonts.inter(
                color: AppColors.brand,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackHistory() {
    // Fallback si falla Supabase
    final mockHistory = [
      _FallbackItem(
        'Derivadas parciales',
        'Matemática · Prof. Carlos M.',
        '14 Feb 2026',
        20.0,
        5,
      ),
      _FallbackItem(
        'Termodinámica',
        'Ciencias · Dra. Sofía R.',
        '12 Feb 2026',
        25.0,
        4,
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${mockHistory.length} sesiones (offline)',
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.muted),
        ),
        const SizedBox(height: 16),
        ...mockHistory.map((item) => _FallbackCard(item: item)),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final SesionModel sesion;
  const _HistoryCard({required this.sesion});

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sesion.temaDescripcion ?? 'Sin tema',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${sesion.materiaNombre ?? "Materia"} · ${sesion.docenteNombre ?? "Profesor"}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'S/ ${sesion.costoTotal.toStringAsFixed(0)}',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: AppColors.brand,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: sesion.estado == 'Finalizada'
                      ? AppColors.ok.withValues(alpha: 0.1)
                      : AppColors.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  sesion.estado,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: sesion.estado == 'Finalizada'
                        ? AppColors.ok
                        : AppColors.danger,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                sesion.modalidad.replaceAll('_', ' '),
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.muted),
              ),
              const Spacer(),
              if (sesion.fechaFin != null)
                Text(
                  '${sesion.fechaFin!.day}/${sesion.fechaFin!.month}/${sesion.fechaFin!.year}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.muted,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FallbackItem {
  final String tema;
  final String subtitle;
  final String fecha;
  final double costo;
  final int rating;
  const _FallbackItem(
    this.tema,
    this.subtitle,
    this.fecha,
    this.costo,
    this.rating,
  );
}

class _FallbackCard extends StatelessWidget {
  final _FallbackItem item;
  const _FallbackCard({required this.item});

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.tema,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      item.subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'S/ ${item.costo.toStringAsFixed(0)}',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: AppColors.brand,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ...List.generate(
                5,
                (i) => Icon(
                  i < item.rating
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  size: 16,
                  color: AppColors.warn,
                ),
              ),
              const Spacer(),
              Text(
                item.fecha,
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
