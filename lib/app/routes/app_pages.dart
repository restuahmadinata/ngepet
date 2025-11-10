import 'package:get/get.dart';

// Auth Feature
import '../features/auth/modules/login/login_binding.dart';
import '../features/auth/modules/login/login_view.dart';
import '../features/auth/modules/starter/starter_binding.dart';
import '../features/auth/modules/starter/starter_view.dart';
import '../features/auth/modules/register/register_binding.dart';
import '../features/auth/modules/register/register_view.dart';
import '../features/auth/modules/splash/splash_view.dart';
import '../features/auth/modules/splash/splash_binding.dart';

// User Feature
import '../features/user/modules/home/home_view.dart';
import '../features/user/modules/home/home_binding.dart';
import '../features/user/modules/adopt/adopt_view.dart';
import '../features/user/modules/chat/chat_view.dart';
import '../features/user/modules/profile/profile_view.dart';

// Shared Feature
import '../features/shared/modules/event/event_view.dart';

// Shelter Feature
import '../features/shelter/modules/shelter/verification/verification_view.dart';
import '../features/shelter/modules/shelter/verification/verification_binding.dart';
import '../features/shelter/modules/shelter/home/shelter_home_view.dart';
import '../features/shelter/modules/shelter/home/shelter_home_binding.dart';
import '../features/shelter/modules/shelter/add_pet/add_pet_view.dart';
import '../features/shelter/modules/shelter/add_pet/add_pet_binding.dart';
import '../features/shelter/modules/shelter/add_event/add_event_view.dart';
import '../features/shelter/modules/shelter/add_event/add_event_binding.dart';

// Admin Feature
import '../features/admin/modules/home/admin_home_view.dart';
import '../features/admin/modules/home/admin_home_binding.dart';
import '../features/admin/modules/user_management/user_management_view.dart';
import '../features/admin/modules/user_management/user_management_binding.dart';
import '../features/admin/modules/shelter_verification/shelter_verification_view.dart';
import '../features/admin/modules/shelter_verification/shelter_verification_binding.dart';

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
    GetPage(name: AppRoutes.adopt, page: () => const AdoptView()),
    GetPage(name: AppRoutes.event, page: () => const EventView()),
    GetPage(name: AppRoutes.chat, page: () => const ChatView()),
    GetPage(name: AppRoutes.profile, page: () => const ProfileView()),

    // --- VERIFICATION PAGE ---
    GetPage(
      name: AppRoutes.verification,
      page: () => const VerificationView(),
      binding: VerificationBinding(),
    ),

    // --- SHELTER HOME PAGE ---
    GetPage(
      name: AppRoutes.shelterHome,
      page: () => const ShelterHomeView(),
      binding: ShelterHomeBinding(),
    ),

    // --- SHELTER ADD PET PAGE ---
    GetPage(
      name: AppRoutes.shelterAddPet,
      page: () => const AddPetView(),
      binding: AddPetBinding(),
    ),

    // --- SHELTER ADD EVENT PAGE ---
    GetPage(
      name: AppRoutes.shelterAddEvent,
      page: () => const AddEventView(),
      binding: AddEventBinding(),
    ),

    // --- ADMIN HOME PAGE ---
    GetPage(
      name: AppRoutes.adminHome,
      page: () => const AdminHomeView(),
      binding: AdminHomeBinding(),
    ),

    // --- ADMIN USER MANAGEMENT PAGE ---
    GetPage(
      name: AppRoutes.adminUserManagement,
      page: () => const UserManagementView(),
      binding: UserManagementBinding(),
    ),

    // --- ADMIN SHELTER VERIFICATION PAGE ---
    GetPage(
      name: AppRoutes.adminShelterVerification,
      page: () => const ShelterVerificationView(),
      binding: ShelterVerificationBinding(),
    ),
  ];
}
