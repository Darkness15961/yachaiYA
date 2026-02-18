import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:yachaiya/core/theme/app_theme.dart';
import 'package:yachaiya/core/services/auth_service.dart';
import 'package:yachaiya/data/providers/app_providers.dart';

class TeacherProfileScreen extends ConsumerWidget {
  const TeacherProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doc = ref.watch(mockDocenteProvider);
    final fotoUrl = doc?.fotoPerfil;
    final resenasAsync = doc != null
        ? ref.watch(resenasDocenteProvider(doc.id))
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Profile Header ──
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.line),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                // Foto / Avatar
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.3),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.2),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: fotoUrl != null
                        ? CachedNetworkImage(
                            imageUrl: fotoUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => _buildAvatarFallback(doc),
                            errorWidget: (_, __, ___) =>
                                _buildAvatarFallback(doc),
                          )
                        : _buildAvatarFallback(doc),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  doc?.nombreCompleto ?? 'Docente',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    doc?.biografiaCorta ?? 'Docente verificado',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF059669),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  doc?.email ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 20),

                // Stats row
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatItem(
                        label: 'Rating',
                        value: doc?.ratingPromedio.toStringAsFixed(1) ?? "5.0",
                        icon: Icons.star_rounded,
                        color: AppColors.warn,
                      ),
                      Container(width: 1, height: 36, color: AppColors.line),
                      _StatItem(
                        label: 'Reseñas',
                        value: '${resenasAsync?.valueOrNull?.length ?? 0}',
                        icon: Icons.rate_review_rounded,
                        color: const Color(0xFF8B5CF6),
                      ),
                      Container(width: 1, height: 36, color: AppColors.line),
                      _StatItem(
                        label: 'Saldo',
                        value:
                            'S/ ${doc?.saldoActual.toStringAsFixed(0) ?? "0"}',
                        icon: Icons.account_balance_wallet_rounded,
                        color: AppColors.brand,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 20),

          // ── Reseñas Section ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reseñas de Estudiantes',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (resenasAsync?.valueOrNull != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warn.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: AppColors.warn,
                        size: 14,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        doc?.ratingPromedio.toStringAsFixed(1) ?? '5.0',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.warn,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 12),

          // Reseñas cards
          if (resenasAsync != null)
            resenasAsync.when(
              data: (resenas) {
                if (resenas.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.warn.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.star_border_rounded,
                            size: 36,
                            color: AppColors.warn.withValues(alpha: 0.4),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Aún no tienes reseñas',
                          style: GoogleFonts.inter(
                            color: AppColors.muted,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tus estudiantes podrán evaluarte aquí',
                          style: GoogleFonts.inter(
                            color: AppColors.muted.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 150.ms);
                }
                return Column(
                  children: resenas.asMap().entries.map((entry) {
                    final i = entry.key;
                    final r = entry.value;
                    return _ResenaCard(resena: r).animate().fadeIn(
                      delay: Duration(milliseconds: 150 + i * 80),
                    );
                  }).toList(),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(30),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF10B981)),
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),

          const SizedBox(height: 16),

          // ── Options ──
          _OptionTile(
            icon: Icons.person_rounded,
            label: 'Editar Perfil',
            subtitle: 'Actualiza tu información y foto',
            color: const Color(0xFF10B981),
            onTap: () {},
          ).animate().fadeIn(delay: 200.ms),

          _OptionTile(
            icon: Icons.menu_book_rounded,
            label: 'Mis Especialidades',
            subtitle: 'Gestiona las materias que enseñas',
            color: const Color(0xFF8B5CF6),
            onTap: () {},
          ).animate().fadeIn(delay: 250.ms),

          _OptionTile(
            icon: Icons.notifications_rounded,
            label: 'Notificaciones',
            subtitle: 'Configura alertas de solicitudes',
            color: AppColors.warn,
            onTap: () {},
          ).animate().fadeIn(delay: 300.ms),

          _OptionTile(
            icon: Icons.swap_horiz_rounded,
            label: 'Cambiar a Vista Estudiante',
            subtitle: 'Accede a tu perfil de alumno',
            color: AppColors.brand,
            onTap: () {
              ref.read(currentRoleProvider.notifier).state =
                  UserRole.estudiante;
              context.go('/student');
            },
          ).animate().fadeIn(delay: 350.ms),

          _OptionTile(
            icon: Icons.logout_rounded,
            label: 'Cerrar Sesión',
            subtitle: 'Salir de tu cuenta',
            color: AppColors.danger,
            isDestructive: true,
            onTap: () async {
              await AuthService.signOut();
              ref.read(currentRoleProvider.notifier).state = UserRole.none;
              ref.read(mockDocenteProvider.notifier).state = null;
              ref.read(mockEstudianteProvider.notifier).state = null;
              if (context.mounted) context.go('/');
            },
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(dynamic doc) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
        ),
      ),
      child: Center(
        child: Text(
          doc?.iniciales ?? '?',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

// ── Reseña Card ──
class _ResenaCard extends StatelessWidget {
  final dynamic resena;
  const _ResenaCard({required this.resena});

  @override
  Widget build(BuildContext context) {
    final calificacion = resena.calificacion as int;
    final nombre = resena.estudianteNombre as String? ?? 'Estudiante';
    final comentario = resena.comentario as String?;
    final fecha = resena.fechaCreacion as DateTime;
    final foto = resena.estudianteFoto as String?;

    final diasAtras = DateTime.now().difference(fecha).inDays;
    final tiempoStr = diasAtras == 0
        ? 'Hoy'
        : diasAtras == 1
        ? 'Ayer'
        : 'Hace $diasAtras días';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Foto estudiante
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.brand.withValues(alpha: 0.1),
                ),
                child: ClipOval(
                  child: foto != null
                      ? CachedNetworkImage(
                          imageUrl: foto,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Center(
                            child: Text(
                              nombre.substring(0, 1).toUpperCase(),
                              style: GoogleFonts.inter(
                                color: AppColors.brand,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Center(
                            child: Text(
                              nombre.substring(0, 1).toUpperCase(),
                              style: GoogleFonts.inter(
                                color: AppColors.brand,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            nombre.substring(0, 1).toUpperCase(),
                            style: GoogleFonts.inter(
                              color: AppColors.brand,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      tiempoStr,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              // Estrellas
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (i) {
                  return Icon(
                    i < calificacion
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: AppColors.warn,
                    size: 18,
                  );
                }),
              ),
            ],
          ),
          if (comentario != null && comentario.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '"$comentario"',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textDark,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Stat Item ──
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 14),
        ),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, color: AppColors.muted),
        ),
      ],
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isDestructive
                              ? AppColors.danger
                              : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.muted.withValues(alpha: 0.4),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
