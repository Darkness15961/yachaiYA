import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yachaiya/core/theme/app_theme.dart';
import 'package:yachaiya/core/services/auth_service.dart';
import 'package:yachaiya/data/providers/app_providers.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  bool _loading = false;
  bool _showRoleSelection = false;
  String? _userName;
  String? _userPhoto;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    // Verificar si ya hay sesión activa
    final user = AuthService.currentUser;
    if (user != null) {
      _onUserAuthenticated(user);
    }

    // Escuchar cambios de auth (para cuando vuelve del redirect de Google)
    _authSub = AuthService.onAuthStateChange.listen((authState) {
      if (authState.event == AuthChangeEvent.signedIn &&
          authState.session != null) {
        _onUserAuthenticated(authState.session!.user);
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  void _onUserAuthenticated(User user) {
    if (!mounted) return;
    final metadata = user.userMetadata;
    setState(() {
      _showRoleSelection = true;
      _userName =
          metadata?['full_name'] as String? ??
          metadata?['name'] as String? ??
          user.email?.split('@').first ??
          'Usuario';
      _userPhoto =
          metadata?['avatar_url'] as String? ?? metadata?['picture'] as String?;
      _loading = false;
    });
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      await AuthService.signInWithGoogle();
      // En web, el usuario será redirigido a Google
      // El listener de onAuthStateChange manejará el retorno
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al iniciar sesión: $e'),
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

  Future<void> _selectRole(UserRole role) async {
    setState(() => _loading = true);
    try {
      if (role == UserRole.estudiante) {
        final est = await AuthService.findOrCreateEstudiante();
        ref.read(currentRoleProvider.notifier).state = UserRole.estudiante;
        ref.read(mockEstudianteProvider.notifier).state = est;
        if (mounted) context.go('/student');
      } else {
        final doc = await AuthService.findOrCreateDocente();
        ref.read(currentRoleProvider.notifier).state = UserRole.docente;
        ref.read(mockDocenteProvider.notifier).state = doc;
        if (mounted) context.go('/teacher');
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al configurar perfil: $e'),
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
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.5, -0.8),
                radius: 1.8,
                colors: [
                  AppColors.brand.withValues(alpha: 0.12),
                  Colors.transparent,
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    // Logo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: AppColors.primaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brand.withValues(alpha: 0.35),
                            blurRadius: 30,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Y',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ).animate().scale(
                      duration: 600.ms,
                      curve: Curves.elasticOut,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'YachaiYA',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 6),
                    Text(
                      'Asesoría Académica al Instante',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.muted,
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                    const Spacer(flex: 2),

                    // Mostrar selección de rol o botón de Google
                    if (_showRoleSelection)
                      _buildRoleSelection()
                    else
                      _buildGoogleLogin(),

                    const Spacer(flex: 3),
                  ],
                ),
              ),
            ),
          ),
          if (_loading)
            Container(
              color: Colors.black26,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [appShadow],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: AppColors.brand),
                      const SizedBox(height: 16),
                      Text(
                        'Conectando...',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildGoogleLogin() {
    return Column(
      children: [
        Text(
          'Inicia sesión para comenzar',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 20),
        // Botón Google
        Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _loading ? null : _signInWithGoogle,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.line),
                    boxShadow: const [appShadow],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Google icon
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Center(
                          child: Text(
                            'G',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF4285F4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Continuar con Google',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .animate()
            .slideY(begin: 0.3, delay: 500.ms, duration: 400.ms)
            .fadeIn(),
      ],
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      children: [
        // Bienvenida con foto
        if (_userPhoto != null)
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(_userPhoto!),
            backgroundColor: AppColors.line,
          ).animate().scale(duration: 300.ms),
        if (_userPhoto != null) const SizedBox(height: 10),
        Text(
          '¡Hola, $_userName! 👋',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 6),
        Text(
          '¿Cómo quieres ingresar?',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.muted),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 20),
        // Rol Estudiante
        _RoleButton(
              icon: Icons.school_rounded,
              title: 'Soy Estudiante',
              subtitle: 'Busca un profesor para tu consulta',
              gradient: AppColors.primaryGradient,
              onTap: _loading ? null : () => _selectRole(UserRole.estudiante),
            )
            .animate()
            .slideX(begin: -0.3, delay: 300.ms, duration: 400.ms)
            .fadeIn(),
        const SizedBox(height: 14),
        // Rol Profesor
        _RoleButton(
              icon: Icons.cast_for_education_rounded,
              title: 'Soy Profesor',
              subtitle: 'Conecta con alumnos que te necesitan',
              gradient: AppColors.okGradient,
              onTap: _loading ? null : () => _selectRole(UserRole.docente),
            )
            .animate()
            .slideX(begin: 0.3, delay: 400.ms, duration: 400.ms)
            .fadeIn(),
        const SizedBox(height: 14),
        // Cerrar sesión / cambiar cuenta
        TextButton.icon(
          onPressed: () async {
            await AuthService.signOut();
            setState(() {
              _showRoleSelection = false;
              _userName = null;
              _userPhoto = null;
            });
          },
          icon: const Icon(Icons.logout_rounded, size: 16),
          label: Text(
            'Usar otra cuenta',
            style: GoogleFonts.inter(fontSize: 13),
          ),
        ).animate().fadeIn(delay: 500.ms),
      ],
    );
  }
}

class _RoleButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback? onTap;

  const _RoleButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.line),
            boxShadow: const [appShadow],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.colors.first.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
