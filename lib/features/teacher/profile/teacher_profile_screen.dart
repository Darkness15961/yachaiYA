import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:yachaiya/core/theme/app_theme.dart';
import 'package:yachaiya/core/services/auth_service.dart';
import 'package:yachaiya/data/providers/app_providers.dart';

class TeacherProfileScreen extends ConsumerWidget {
  const TeacherProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doc = ref.watch(mockDocenteProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.line),
              boxShadow: const [appShadow],
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppColors.okGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.ok.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      doc?.iniciales ?? 'SR',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  doc?.nombreCompleto ?? 'Sofía Ramírez',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  doc?.biografiaCorta ?? 'Especialista en Matemáticas',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.muted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatItem(
                      label: 'Rating',
                      value: '${doc?.ratingPromedio ?? 4.8}',
                      icon: Icons.star_rounded,
                      color: AppColors.warn,
                    ),
                    Container(width: 1, height: 40, color: AppColors.line),
                    _StatItem(
                      label: 'Tarifa/min',
                      value:
                          'S/ ${doc?.tarifaBaseMinuto.toStringAsFixed(1) ?? "1.5"}',
                      icon: Icons.timer_rounded,
                      color: AppColors.brand,
                    ),
                    Container(width: 1, height: 40, color: AppColors.line),
                    _StatItem(
                      label: 'Sesiones',
                      value: '24',
                      icon: Icons.school_rounded,
                      color: AppColors.ok,
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 16),

          _OptionTile(
            icon: Icons.person_rounded,
            label: 'Editar Perfil',
            onTap: () {},
          ).animate().fadeIn(delay: 100.ms),
          _OptionTile(
            icon: Icons.menu_book_rounded,
            label: 'Mis Especialidades',
            onTap: () {},
          ).animate().fadeIn(delay: 150.ms),
          _OptionTile(
            icon: Icons.notifications_rounded,
            label: 'Notificaciones',
            onTap: () {},
          ).animate().fadeIn(delay: 200.ms),
          _OptionTile(
            icon: Icons.settings_rounded,
            label: 'Configuración',
            onTap: () {},
          ).animate().fadeIn(delay: 250.ms),
          _OptionTile(
            icon: Icons.logout_rounded,
            label: 'Cerrar Sesión',
            isDestructive: true,
            onTap: () async {
              await AuthService.signOut();
              ref.read(currentRoleProvider.notifier).state = UserRole.none;
              ref.read(mockDocenteProvider.notifier).state = null;
              if (context.mounted) context.go('/');
            },
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }
}

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
        Icon(icon, color: color, size: 20),
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

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: isDestructive ? AppColors.danger : AppColors.ok,
        ),
        title: Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: isDestructive ? AppColors.danger : AppColors.textDark,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: AppColors.muted,
          size: 20,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
