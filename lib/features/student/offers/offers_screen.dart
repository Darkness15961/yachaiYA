import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:yachaiya/core/theme/app_theme.dart';
import 'package:yachaiya/data/providers/app_providers.dart';
import 'package:yachaiya/data/models/oferta_docente_model.dart';

class OffersScreen extends ConsumerWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materia = ref.watch(selectedMateriaProvider);
    final sesion = ref.watch(currentSesionProvider);
    final ofertasAsync = sesion != null
        ? ref.watch(ofertasSesionProvider(sesion.id))
        : null;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.line),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(18),
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
                          Text(
                            'Profesores Disponibles',
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppColors.okGradient,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'En línea',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (materia != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Área: ${materia.nombre}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      // Ofertas reales o vacías
                      Expanded(
                        child: _buildOfertasList(context, ref, ofertasAsync),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfertasList(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<OfertaDocenteModel>>? ofertasAsync,
  ) {
    if (ofertasAsync == null) {
      return _buildFallbackOfertas(context, ref);
    }

    return ofertasAsync.when(
      data: (ofertas) {
        if (ofertas.isEmpty) {
          return _buildFallbackOfertas(context, ref);
        }
        return ListView.builder(
          itemCount: ofertas.length,
          itemBuilder: (context, i) {
            final o = ofertas[i];
            return _OfferCard(
              nombre: o.docenteNombre ?? 'Profesor',
              especialidad: o.docenteEspecialidad ?? 'Especialista',
              precio: o.precioOfertado,
              rating: o.docenteRating ?? 4.5,
              iniciales: _getInitials(o.docenteNombre),
              mensaje: o.mensaje,
              delay: i * 120,
              onConnect: () {
                _acceptOffer(context, ref, o);
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => _buildFallbackOfertas(context, ref),
    );
  }

  Widget _buildFallbackOfertas(BuildContext context, WidgetRef ref) {
    // Datos de respaldo si no hay ofertas en la BD
    final fallback = [
      ('Prof. Carlos M.', 'Matemática e Ingenierías', 20.0, 4.9, 'CM'),
      ('Dra. Sofía R.', 'Ciencias y Cálculo', 25.0, 4.7, 'SR'),
      ('Ing. Marco A.', 'Programación y Algoritmos', 18.0, 4.8, 'MA'),
    ];
    return ListView.builder(
      itemCount: fallback.length,
      itemBuilder: (_, i) {
        final (nombre, esp, precio, rating, ini) = fallback[i];
        return _OfferCard(
          nombre: nombre,
          especialidad: esp,
          precio: precio,
          rating: rating,
          iniciales: ini,
          delay: i * 120,
          onConnect: () {
            ref.read(sesionEstadoProvider.notifier).state = 'en_sesion';
            context.pushReplacement('/student/session');
          },
        );
      },
    );
  }

  void _acceptOffer(BuildContext context, WidgetRef ref, OfertaDocenteModel o) {
    ref.read(sesionEstadoProvider.notifier).state = 'en_sesion';
    context.pushReplacement('/student/session');
  }

  String _getInitials(String? nombre) {
    if (nombre == null || nombre.isEmpty) return '??';
    final parts = nombre.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return nombre[0].toUpperCase();
  }
}

class _OfferCard extends StatelessWidget {
  final String nombre;
  final String especialidad;
  final double precio;
  final double rating;
  final String iniciales;
  final String? mensaje;
  final int delay;
  final VoidCallback onConnect;

  const _OfferCard({
    required this.nombre,
    required this.especialidad,
    required this.precio,
    required this.rating,
    required this.iniciales,
    this.mensaje,
    required this.delay,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    iniciales,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      especialidad,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                    if (mensaje != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '"$mensaje"',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.brand,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: AppColors.warn,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '$rating',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.warn,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'S/ ${precio.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.brand.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: onConnect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Conectar',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: delay),
          duration: 300.ms,
        )
        .slideX(begin: 0.1);
  }
}
