import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:yachaiya/core/theme/app_theme.dart';
import 'package:yachaiya/core/config/supabase_config.dart';
import 'package:yachaiya/data/providers/app_providers.dart';
import 'package:yachaiya/data/models/nivel_materia_model.dart';
import 'package:yachaiya/data/models/sesion_model.dart';

class StudentShell extends ConsumerWidget {
  final Widget child;
  const StudentShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/student/history')) return 1;
    if (location.startsWith('/student/profile')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idx = _currentIndex(context);
    final est = ref.watch(mockEstudianteProvider);
    final fotoUrl = est?.fotoPerfil;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brand.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Y',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YachaiYA',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Asesoría Académica',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (est != null) ...[
            IconButton(
              onPressed: () {},
              icon: Stack(
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    color: AppColors.muted,
                    size: 24,
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () => context.go('/student/profile'),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.brand.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: fotoUrl != null
                        ? CachedNetworkImage(
                            imageUrl: fotoUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => _buildAvatarFallback(est),
                            errorWidget: (_, __, ___) =>
                                _buildAvatarFallback(est),
                          )
                        : _buildAvatarFallback(est),
                  ),
                ),
              ),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton(
                onPressed: () => context.push('/login'),
                child: Text(
                  'Ingresar',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.brand,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: child,

      // ── FAB: Botón de búsqueda (lupa) — solo en Home ──
      floatingActionButton: idx == 0
          ? Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brand.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () => _showNuevaConsulta(context, ref),
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: const Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // ── Bottom Nav ──
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.line),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.08),
              blurRadius: 40,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Inicio',
                  isActive: idx == 0,
                  onTap: () => context.go('/'),
                ),
                _NavItem(
                  icon: Icons.history_rounded,
                  label: 'Historial',
                  isActive: idx == 1,
                  onTap: () {
                    if (est != null) {
                      context.go('/student/history');
                    } else {
                      context.push('/login');
                    }
                  },
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Perfil',
                  isActive: idx == 2,
                  onTap: () {
                    if (est != null) {
                      context.go('/student/profile');
                    } else {
                      context.push('/login');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(dynamic est) {
    return Container(
      color: AppColors.bg,
      child: Center(
        child: Text(
          est?.iniciales ?? '?',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.brand,
          ),
        ),
      ),
    );
  }

  void _showNuevaConsulta(BuildContext context, WidgetRef ref) {
    final est = ref.read(mockEstudianteProvider);

    // Si no está logueado, redirigir a login
    if (est == null) {
      context.push('/login');
      return;
    }

    // Mostrar bottom sheet con formulario de Nueva Consulta
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _NuevaConsultaSheet(parentRef: ref),
    );
  }
}

// ── Bottom Sheet: Nueva Consulta ──
class _NuevaConsultaSheet extends ConsumerStatefulWidget {
  final WidgetRef parentRef;
  const _NuevaConsultaSheet({required this.parentRef});

  @override
  ConsumerState<_NuevaConsultaSheet> createState() =>
      _NuevaConsultaSheetState();
}

class _NuevaConsultaSheetState extends ConsumerState<_NuevaConsultaSheet> {
  final _temaController = TextEditingController();
  bool _loading = false;
  String _tipoClase = 'publica'; // 'publica' o 'privada'

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

    setState(() => _loading = true);

    try {
      final estudiante = ref.read(mockEstudianteProvider);
      final codigoAcceso = _tipoClase == 'privada'
          ? SesionModel.generarCodigo()
          : null;

      final response = await SupabaseConfig.client
          .from('sesion')
          .insert({
            'id_estudiante': estudiante?.id ?? 1,
            'id_materia': materia.id,
            'tema_descripcion': tema,
            'estado': 'Buscando',
            'modalidad': 'Solo_Chat',
            'fecha_inicio': DateTime.now().toIso8601String(),
            'tipo_clase': _tipoClase,
            'codigo_acceso': codigoAcceso,
          })
          .select()
          .single();

      final sesion = SesionModel.fromJson(response);
      ref.read(currentSesionProvider.notifier).state = sesion;
      ref.read(sesionEstadoProvider.notifier).state = 'buscando';

      if (mounted) {
        Navigator.pop(context);
        context.push('/student/searching');
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
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
  }

  @override
  Widget build(BuildContext context) {
    final nivelesAsync = ref.watch(nivelesProvider);
    final selectedNivel = ref.watch(selectedNivelProvider);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
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
            // Handle bar
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

            // Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nueva Consulta',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      'Conecta con un experto ahora',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Tema input
            Text(
              '¿Qué necesitas aprender?',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _temaController,
              decoration: InputDecoration(
                hintText: 'Ej: Derivadas parciales, Ley de Ohm...',
                prefixIcon: Icon(
                  Icons.edit_note_rounded,
                  color: AppColors.muted.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: AppColors.bg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.line.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.brand,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Nivel + Área
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nivel',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      nivelesAsync.when(
                        data: (niveles) {
                          if (selectedNivel == null && niveles.isNotEmpty) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              ref.read(selectedNivelProvider.notifier).state =
                                  niveles.first;
                            });
                          }
                          return _buildDropdown<NivelModel>(
                            value: selectedNivel,
                            items: niveles,
                            labelFn: (n) => n.nombre,
                            onChanged: (v) {
                              ref.read(selectedNivelProvider.notifier).state =
                                  v;
                              ref.read(selectedMateriaProvider.notifier).state =
                                  null;
                            },
                          );
                        },
                        loading: () => const LinearProgressIndicator(),
                        error: (_, __) => _buildFallbackNiveles(),
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
                        'Área',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildAreaDropdown(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Tipo de clase ──
            Text(
              'Tipo de clase',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tipoClase = 'publica'),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _tipoClase == 'publica'
                            ? const Color(0xFF10B981).withValues(alpha: 0.1)
                            : AppColors.bg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _tipoClase == 'publica'
                              ? const Color(0xFF10B981)
                              : AppColors.line,
                          width: _tipoClase == 'publica' ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.public_rounded,
                            color: _tipoClase == 'publica'
                                ? const Color(0xFF10B981)
                                : AppColors.muted,
                            size: 22,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Pública',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _tipoClase == 'publica'
                                  ? const Color(0xFF10B981)
                                  : AppColors.textDark,
                            ),
                          ),
                          Text(
                            'Abierta para todos',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tipoClase = 'privada'),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _tipoClase == 'privada'
                            ? AppColors.warn.withValues(alpha: 0.1)
                            : AppColors.bg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _tipoClase == 'privada'
                              ? AppColors.warn
                              : AppColors.line,
                          width: _tipoClase == 'privada' ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.lock_rounded,
                            color: _tipoClase == 'privada'
                                ? AppColors.warn
                                : AppColors.muted,
                            size: 22,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Privada',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _tipoClase == 'privada'
                                  ? AppColors.warn
                                  : AppColors.textDark,
                            ),
                          ),
                          Text(
                            'Solo con código',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Info de clase privada
            if (_tipoClase == 'privada') ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warn.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.warn.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.warn,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Se generará un código único que podrás compartir con tu profesor.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.warn,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Botón buscar
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
                  onPressed: _loading ? null : _startSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_rounded, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'Buscar Profesor',
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
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<T> items,
    required String Function(T) labelFn,
    required void Function(T?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.bg,
        border: Border.all(color: AppColors.line.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          hint: Text(
            'Seleccionar',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.muted),
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                labelFn(item),
                style: GoogleFonts.inter(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
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
          color: AppColors.bg,
          border: Border.all(color: AppColors.line.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          'Selecciona nivel',
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.muted),
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
        return _buildDropdown<MateriaModel>(
          value: materias.contains(selectedMateria) ? selectedMateria : null,
          items: materias,
          labelFn: (m) => m.nombre,
          onChanged: (v) {
            ref.read(selectedMateriaProvider.notifier).state = v;
          },
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.bg,
          border: Border.all(color: AppColors.line.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          'Error al cargar',
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.danger),
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

    return _buildDropdown<NivelModel>(
      value: selectedNivel,
      items: niveles,
      labelFn: (n) => n.nombre,
      onChanged: (v) {
        ref.read(selectedNivelProvider.notifier).state = v;
        ref.read(selectedMateriaProvider.notifier).state = null;
      },
    );
  }
}

// ── Nav Item ──
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 18 : 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.brand.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive ? AppColors.brand : AppColors.muted,
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brand,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
