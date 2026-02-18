import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:yachaiya/core/theme/app_theme.dart';
import 'package:yachaiya/data/providers/app_providers.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docente = ref.watch(mockDocenteProvider);

    final mockMovimientos = [
      _Movimiento(
        'Sesión con Carlos M.',
        'Ingreso_Clase',
        20.0,
        'Hoy, 3:15 PM',
      ),
      _Movimiento('Comisión App (10%)', 'Comision_App', -2.0, 'Hoy, 3:15 PM'),
      _Movimiento('Sesión con Ana P.', 'Ingreso_Clase', 25.0, 'Ayer, 5:00 PM'),
      _Movimiento('Comisión App (10%)', 'Comision_App', -2.5, 'Ayer, 5:00 PM'),
      _Movimiento('Retiro a Yape', 'Retiro_Yape', -40.0, '10 Feb, 9:30 AM'),
      _Movimiento(
        'Bono de Bienvenida',
        'Bono_Campaña',
        20.0,
        '05 Feb, 0:00 AM',
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //  Saldo Card con glassmorphism
          Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF10B981),
                      Color(0xFF059669),
                      Color(0xFF047857),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.35),
                      blurRadius: 30,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Saldo Disponible',
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Activo',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'S/ ${docente?.saldoActual.toStringAsFixed(2) ?? "0.00"}',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Quick stats
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _QuickStat(
                            icon: Icons.arrow_downward_rounded,
                            label: 'Ingresos',
                            value: '+S/ 65.00',
                          ),
                          Container(
                            width: 1,
                            height: 30,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          _QuickStat(
                            icon: Icons.arrow_upward_rounded,
                            label: 'Retiros',
                            value: '-S/ 40.00',
                          ),
                          Container(
                            width: 1,
                            height: 30,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          _QuickStat(
                            icon: Icons.percent_rounded,
                            label: 'Comisiones',
                            value: '-S/ 4.50',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Botón retirar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Retiro a Yape solicitado (próximamente)',
                              ),
                              backgroundColor: Colors.white,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.send_rounded, size: 18),
                        label: Text(
                          'Retirar a Yape',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF059669),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.95, 0.95)),

          const SizedBox(height: 24),

          // Título movimientos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Movimientos',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.muted.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${mockMovimientos.length} registros',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          ...mockMovimientos.asMap().entries.map((entry) {
            final i = entry.key;
            final mov = entry.value;
            return _MovimientoTile(movimiento: mov).animate().fadeIn(
              delay: Duration(milliseconds: 200 + i * 80),
              duration: 250.ms,
            );
          }),
        ],
      ),
    );
  }
}

// ── Quick Stat ──
class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _QuickStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _Movimiento {
  final String descripcion;
  final String tipo;
  final double monto;
  final String fecha;

  const _Movimiento(this.descripcion, this.tipo, this.monto, this.fecha);
}

class _MovimientoTile extends StatelessWidget {
  final _Movimiento movimiento;

  const _MovimientoTile({required this.movimiento});

  IconData get _icon {
    switch (movimiento.tipo) {
      case 'Ingreso_Clase':
        return Icons.school_rounded;
      case 'Comision_App':
        return Icons.remove_circle_outline_rounded;
      case 'Retiro_Yape':
        return Icons.send_rounded;
      case 'Bono_Campaña':
        return Icons.card_giftcard_rounded;
      default:
        return Icons.receipt_rounded;
    }
  }

  Color get _iconColor {
    if (movimiento.monto >= 0) return const Color(0xFF10B981);
    if (movimiento.tipo == 'Comision_App') return AppColors.warn;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = movimiento.monto >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(_icon, color: _iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movimiento.descripcion,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  movimiento.fecha,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isPositive
                  ? const Color(0xFF10B981).withValues(alpha: 0.08)
                  : AppColors.danger.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${isPositive ? '+' : ''}S/ ${movimiento.monto.toStringAsFixed(2)}',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: isPositive ? const Color(0xFF10B981) : AppColors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
