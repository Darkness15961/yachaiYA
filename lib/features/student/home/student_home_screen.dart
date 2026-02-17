import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:yachaiya/core/theme/app_theme.dart';
import 'package:yachaiya/core/config/supabase_config.dart';
import 'package:yachaiya/data/providers/app_providers.dart';
import 'package:yachaiya/data/models/nivel_materia_model.dart';
import 'package:yachaiya/data/models/sesion_model.dart';

class StudentHomeScreen extends ConsumerStatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  ConsumerState<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends ConsumerState<StudentHomeScreen> {
  final _temaController = TextEditingController();

  @override
  void dispose() {
    _temaController.dispose();
    super.dispose();
  }

  Future<void> _startSearch() async {
    final materia = ref.read(selectedMateriaProvider);
    final tema = _temaController.text.trim();

    if (tema.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ingresa un tema o ejercicio'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (materia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecciona un área'),
          backgroundColor: AppColors.warn,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    try {
      // Crear sesión en Supabase
      final estudiante = ref.read(mockEstudianteProvider);
      final response = await SupabaseConfig.client
          .from('sesion')
          .insert({
            'id_estudiante': estudiante?.id ?? 1,
            'id_materia': materia.id,
            'tema_descripcion': tema,
            'estado': 'Buscando',
            'modalidad': 'Solo_Chat',
            'fecha_inicio': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      final sesion = SesionModel.fromJson(response);
      ref.read(currentSesionProvider.notifier).state = sesion;
      ref.read(sesionEstadoProvider.notifier).state = 'buscando';

      if (mounted) context.push('/student/searching');
    } catch (e) {
      // Si falla Supabase, simulamos localmente
      final mockSesion = SesionModel(
        id: DateTime.now().millisecondsSinceEpoch,
        idEstudiante: 1,
        idMateria: materia.id,
        temaDescripcion: tema,
        estado: 'Buscando',
      );
      ref.read(currentSesionProvider.notifier).state = mockSesion;
      ref.read(sesionEstadoProvider.notifier).state = 'buscando';
      if (mounted) context.push('/student/searching');
    }
  }

  @override
  Widget build(BuildContext context) {
    final nivelesAsync = ref.watch(nivelesProvider);
    final selectedNivel = ref.watch(selectedNivelProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Saludo
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.brand.withValues(alpha: 0.08),
                  AppColors.brand2.withValues(alpha: 0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.brand.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Hola, Carlos! 👋',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '¿En qué te ayudamos hoy?',
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 16,
                        color: AppColors.brand,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'S/ 50.00',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 20),

          // Tarjeta Nueva Consulta
          Container(
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
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.search_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Nueva Consulta',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Tema
                Text(
                  'Tema o Ejercicio',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _temaController,
                  decoration: const InputDecoration(
                    hintText: 'Ej: Derivadas parciales',
                  ),
                ),
                const SizedBox(height: 14),

                // Nivel + Área
                Row(
                  children: [
                    // Nivel
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nivel',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          nivelesAsync.when(
                            data: (niveles) {
                              // Auto-seleccionar el primero
                              if (selectedNivel == null && niveles.isNotEmpty) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  ref
                                          .read(selectedNivelProvider.notifier)
                                          .state =
                                      niveles.first;
                                });
                              }
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.line),
                                  borderRadius: BorderRadius.circular(14),
                                  color: Colors.white,
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<NivelModel>(
                                    isExpanded: true,
                                    value: selectedNivel,
                                    hint: const Text('Seleccionar'),
                                    items: niveles.map((n) {
                                      return DropdownMenuItem(
                                        value: n,
                                        child: Text(
                                          n.nombre,
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (v) {
                                      ref
                                              .read(
                                                selectedNivelProvider.notifier,
                                              )
                                              .state =
                                          v;
                                      ref
                                              .read(
                                                selectedMateriaProvider
                                                    .notifier,
                                              )
                                              .state =
                                          null;
                                    },
                                  ),
                                ),
                              );
                            },
                            loading: () => const LinearProgressIndicator(),
                            error: (_, __) => _buildFallbackNiveles(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Área
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Área',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _buildAreaDropdown(),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Botón buscar
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.brand.withValues(alpha: 0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _startSearch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Buscar Profesor',
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
          ).animate().fadeIn(delay: 150.ms, duration: 300.ms),
        ],
      ),
    );
  }

  Widget _buildAreaDropdown() {
    final selectedNivel = ref.watch(selectedNivelProvider);
    final selectedMateria = ref.watch(selectedMateriaProvider);

    if (selectedNivel == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(14),
          color: Colors.white,
        ),
        child: Text(
          'Selecciona nivel',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.muted),
        ),
      );
    }

    final materiasAsync = ref.watch(materiasByNivelProvider(selectedNivel.id));

    return materiasAsync.when(
      data: (materias) {
        if (selectedMateria == null && materias.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(selectedMateriaProvider.notifier).state = materias.first;
          });
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(14),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<MateriaModel>(
              isExpanded: true,
              value: materias.contains(selectedMateria)
                  ? selectedMateria
                  : null,
              hint: const Text('Seleccionar'),
              items: materias.map((m) {
                return DropdownMenuItem(
                  value: m,
                  child: Text(
                    m.nombre,
                    style: GoogleFonts.inter(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (v) {
                ref.read(selectedMateriaProvider.notifier).state = v;
              },
            ),
          ),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(14),
          color: Colors.white,
        ),
        child: Text(
          'Error al cargar',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.danger),
        ),
      ),
    );
  }

  Widget _buildFallbackNiveles() {
    final niveles = [
      NivelModel(id: 1, nombre: 'Primaria'),
      NivelModel(id: 2, nombre: 'Secundaria'),
      NivelModel(id: 3, nombre: 'Universitario'),
    ];
    final selectedNivel = ref.watch(selectedNivelProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<NivelModel>(
          isExpanded: true,
          value: selectedNivel,
          items: niveles.map((n) {
            return DropdownMenuItem(
              value: n,
              child: Text(n.nombre, style: GoogleFonts.inter(fontSize: 14)),
            );
          }).toList(),
          onChanged: (v) {
            ref.read(selectedNivelProvider.notifier).state = v;
            ref.read(selectedMateriaProvider.notifier).state = null;
          },
        ),
      ),
    );
  }
}
