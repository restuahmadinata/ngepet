import 'package:get/get.dart';
import '../modules/auth/login/login_binding.dart';
import '../modules/auth/login/login_view.dart';
import '../modules/auth/starter/starter_binding.dart';
import '../modules/auth/starter/starter_view.dart';
import '../modules/auth/register/register_binding.dart';
import '../modules/auth/register/register_view.dart';
import '../modules/home/home_view.dart';
import '../modules/home/home_binding.dart';
import '../modules/adopt/adopt_view.dart';
import '../modules/event/event_view.dart';
import '../modules/chat/chat_view.dart';
import '../modules/profile/profile_view.dart';
import '../modules/splash/splash_view.dart';
import '../modules/splash/splash_binding.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  // Halaman awal aplikasi sekarang splash
  static const initial = AppRoutes.splash;

  static final routes = [
    // --- SPLASH PAGE ---
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),

    // --- STARTER PAGE ---
    GetPage(
      name: AppRoutes.starter,
      page: () => const StarterView(),
      binding: StarterBinding(),
    ),

    // --- LOGIN PAGE ---
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),

    // --- REGISTER PAGE ---
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),

    // --- USER HOME PAGE (with Bottom Nav) ---
    GetPage(
      name: AppRoutes.userHome,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),

    // --- Bottom Nav Pages (for direct navigation if needed) ---
    GetPage(
      name: AppRoutes.adopt,
      page: () => const AdoptView(),
    ),
    GetPage(
      name: AppRoutes.event,
      page: () => const EventView(),
    ),
    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatView(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
    ),
  ];
}