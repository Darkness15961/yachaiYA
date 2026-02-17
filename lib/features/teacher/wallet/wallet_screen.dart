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
      _Movimiento('Sesión con Carlos M.', 'Ingreso_Clase', 20.0, '14 Feb'),
      _Movimiento('Comisión App (10%)', 'Comision_App', -2.0, '14 Feb'),
      _Movimiento('Sesión con Ana P.', 'Ingreso_Clase', 25.0, '12 Feb'),
      _Movimiento('Comisión App (10%)', 'Comision_App', -2.5, '12 Feb'),
      _Movimiento('Retiro a Yape', 'Retiro_Yape', -40.0, '10 Feb'),
      _Movimiento('Bono de Bienvenida', 'Bono_Campaña', 20.0, '05 Feb'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta de saldo
          Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brand.withValues(alpha: 0.35),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saldo Disponible',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'S/ ${docente?.saldoActual.toStringAsFixed(2) ?? "120.00"}',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Retiro a Yape solicitado (próximamente)',
                              ),
                              backgroundColor: AppColors.brand,
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
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 300.ms)
              .scale(begin: const Offset(0.95, 0.95)),

          const SizedBox(height: 24),

          Text(
            'Movimientos',
            style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),

          ...mockMovimientos.asMap().entries.map((entry) {
            final i = entry.key;
            final mov = entry.value;
            return _MovimientoTile(movimiento: mov).animate().fadeIn(
              delay: Duration(milliseconds: i * 80),
              duration: 250.ms,
            );
          }),
        ],
      ),
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
    if (movimiento.monto >= 0) return AppColors.ok;
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
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
                Text(
                  movimiento.fecha,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isPositive ? '+' : ''}S/ ${movimiento.monto.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: isPositive ? AppColors.ok : AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}
