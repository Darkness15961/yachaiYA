import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yachaiya/data/providers/app_providers.dart';
import 'package:yachaiya/features/auth/role_selection_screen.dart';
import 'package:yachaiya/features/student/student_shell.dart';
import 'package:yachaiya/features/student/home/student_home_screen.dart';
import 'package:yachaiya/features/student/searching/searching_screen.dart';
import 'package:yachaiya/features/student/offers/offers_screen.dart';
import 'package:yachaiya/features/student/session/session_screen.dart';
import 'package:yachaiya/features/student/history/history_screen.dart';
import 'package:yachaiya/features/student/profile/student_profile_screen.dart';
import 'package:yachaiya/features/teacher/teacher_shell.dart';
import 'package:yachaiya/features/teacher/dashboard/teacher_dashboard_screen.dart';
import 'package:yachaiya/features/teacher/events/events_screen.dart';
import 'package:yachaiya/features/teacher/wallet/wallet_screen.dart';
import 'package:yachaiya/features/teacher/profile/teacher_profile_screen.dart';
import 'package:yachaiya/features/teacher/session/teacher_session_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _studentShellKey = GlobalKey<NavigatorState>();
final _teacherShellKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  ref.watch(currentRoleProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      // ===== HOME PÚBLICO (sin auth) =====
      ShellRoute(
        navigatorKey: _studentShellKey,
        builder: (context, state, child) => StudentShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: StudentHomeScreen()),
          ),
          GoRoute(
            path: '/student',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: StudentHomeScreen()),
          ),
          GoRoute(
            path: '/student/history',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HistoryScreen()),
          ),
          GoRoute(
            path: '/student/profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: StudentProfileScreen()),
          ),
        ],
      ),

      // Login
      GoRoute(
        path: '/login',
        builder: (context, state) => const RoleSelectionScreen(),
      ),

      // Pantallas de flujo (sin tab bar)
      GoRoute(
        path: '/student/searching',
        builder: (context, state) => const SearchingScreen(),
      ),
      GoRoute(
        path: '/student/offers',
        builder: (context, state) => const OffersScreen(),
      ),
      GoRoute(
        path: '/student/session',
        builder: (context, state) => const SessionScreen(),
      ),

      // ===== PROFESOR =====
      ShellRoute(
        navigatorKey: _teacherShellKey,
        builder: (context, state, child) => TeacherShell(child: child),
        routes: [
          GoRoute(
            path: '/teacher',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: TeacherDashboardScreen()),
          ),
          GoRoute(
            path: '/teacher/events',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: EventsScreen()),
          ),
          GoRoute(
            path: '/teacher/wallet',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: WalletScreen()),
          ),
          GoRoute(
            path: '/teacher/profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: TeacherProfileScreen()),
          ),
        ],
      ),

      // Sesión profesor (sin tab bar)
      GoRoute(
        path: '/teacher/session',
        builder: (context, state) => const TeacherSessionScreen(),
      ),
    ],
  );
});
