import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:yachaiya/core/theme/app_theme.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  final _mockEventos = [
    _EventoItem(
      titulo: 'Taller de Cálculo Integral',
      materia: 'Matemática',
      fecha: '20 Feb 2026, 3:00 PM',
      duracion: 90,
      participantes: 3,
      maxParticipantes: 10,
      precio: 15.0,
    ),
    _EventoItem(
      titulo: 'Repaso de Física Mecánica',
      materia: 'Ciencias',
      fecha: '22 Feb 2026, 5:00 PM',
      duracion: 60,
      participantes: 7,
      maxParticipantes: 8,
      precio: 10.0,
    ),
  ];

  void _showCrearEventoDialog() {
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
              const SizedBox(height: 18),
              Text(
                'Crear Evento',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Título',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.muted),
              ),
              const SizedBox(height: 6),
              const TextField(
                decoration: InputDecoration(hintText: 'Ej: Taller de Cálculo'),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Precio (S/)',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '15',
                            prefixText: 'S/ ',
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
                          'Max. participantes',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(hintText: '10'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Descripción',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.muted),
              ),
              const SizedBox(height: 6),
              const TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Describe el contenido del evento...',
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
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('¡Evento creado!'),
                          backgroundColor: AppColors.ok,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Crear Evento',
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mis Eventos',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Crea clases grupales para encontrar alumnos',
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.muted),
              ),
              const SizedBox(height: 16),
              ..._mockEventos.asMap().entries.map((entry) {
                final i = entry.key;
                final ev = entry.value;
                return _EventoCard(evento: ev).animate().fadeIn(
                  delay: Duration(milliseconds: i * 100),
                  duration: 300.ms,
                );
              }),
            ],
          ),
        ),
        // FAB
        Positioned(
          right: 16,
          bottom: 16,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.okGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ok.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: _showCrearEventoDialog,
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: const Icon(Icons.add_rounded, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _EventoItem {
  final String titulo;
  final String materia;
  final String fecha;
  final int duracion;
  final int participantes;
  final int maxParticipantes;
  final double precio;

  const _EventoItem({
    required this.titulo,
    required this.materia,
    required this.fecha,
    required this.duracion,
    required this.participantes,
    required this.maxParticipantes,
    required this.precio,
  });
}

class _EventoCard extends StatelessWidget {
  final _EventoItem evento;

  const _EventoCard({required this.evento});

  @override
  Widget build(BuildContext context) {
    final progreso = evento.participantes / evento.maxParticipantes;

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
                child: Text(
                  evento.titulo,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                'S/ ${evento.precio.toStringAsFixed(0)}',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: AppColors.ok,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: AppColors.muted,
              ),
              const SizedBox(width: 6),
              Text(
                evento.fecha,
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.muted),
              ),
              const SizedBox(width: 12),
              Icon(Icons.timer_rounded, size: 14, color: AppColors.muted),
              const SizedBox(width: 4),
              Text(
                '${evento.duracion} min',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Barra progreso
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progreso,
                    minHeight: 8,
                    backgroundColor: AppColors.line,
                    valueColor: AlwaysStoppedAnimation(
                      progreso > 0.8 ? AppColors.warn : AppColors.ok,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${evento.participantes}/${evento.maxParticipantes}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
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
