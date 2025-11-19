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
import '../features/auth/modules/suspended/suspended_account_view.dart';
import '../features/auth/modules/suspended/suspended_account_binding.dart';

// User Feature
import '../features/user/modules/home/home_view.dart';
import '../features/user/modules/home/home_binding.dart';
import '../features/user/modules/adopt/adopt_view.dart';
import '../features/user/modules/chat/chat_view.dart';
import '../features/user/modules/profile/profile_view.dart';
import '../features/user/modules/profile/edit_profile/edit_profile_view.dart';
import '../features/user/modules/profile/edit_profile/edit_profile_binding.dart';
import '../features/user/modules/adoption_request/adoption_request_view.dart';
import '../features/user/modules/adoption_request/adoption_request_binding.dart';
import '../features/user/modules/adoption_status/adoption_status_view.dart';
import '../features/user/modules/adoption_status/adoption_status_binding.dart';
import '../features/user/modules/following/following_view.dart';
import '../features/user/modules/following/following_binding.dart';

// Shared Feature
import '../features/shared/modules/event/event_view.dart';
import '../features/shared/modules/shelter_profile/shelter_profile_view.dart';
import '../features/shared/modules/shelter_profile/shelter_profile_binding.dart';

// Shelter Feature
import '../features/shelter/modules/shelter/verification/verification_view.dart';
import '../features/shelter/modules/shelter/verification/verification_binding.dart';
import '../features/shelter/modules/shelter/navigation/shelter_navigation_view.dart';
import '../features/shelter/modules/shelter/navigation/shelter_navigation_binding.dart';
import '../features/shelter/modules/shelter/add_pet/add_pet_view.dart';
import '../features/shelter/modules/shelter/add_pet/add_pet_binding.dart';
import '../features/shelter/modules/shelter/add_event/add_event_view.dart';
import '../features/shelter/modules/shelter/add_event/add_event_binding.dart';
import '../features/shelter/modules/shelter/manage_pets/manage_pets_view.dart';
import '../features/shelter/modules/shelter/manage_pets/manage_pets_binding.dart';
import '../features/shelter/modules/shelter/manage_events/manage_events_view.dart';
import '../features/shelter/modules/shelter/manage_events/manage_events_binding.dart';
import '../features/shelter/modules/shelter/edit_pet/edit_pet_view.dart';
import '../features/shelter/modules/shelter/edit_pet/edit_pet_binding.dart';
import '../features/shelter/modules/shelter/edit_event/edit_event_view.dart';
import '../features/shelter/modules/shelter/edit_event/edit_event_binding.dart';
import '../features/shelter/modules/shelter/profile/edit_shelter_profile_view.dart';
import '../features/shelter/modules/shelter/profile/edit_shelter_profile_binding.dart';
import '../features/shelter/modules/shelter/adoption_management/adoption_management_view.dart';
import '../features/shelter/modules/shelter/adoption_management/adoption_management_binding.dart';
import '../features/shelter/modules/shelter/followers/followers_view.dart';
import '../features/shelter/modules/shelter/followers/followers_binding.dart';

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

    // --- EDIT PROFILE PAGE ---
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
    ),

    // --- ADOPTION REQUEST PAGE ---
    GetPage(
      name: AppRoutes.adoptionRequest,
      page: () => const AdoptionRequestView(),
      binding: AdoptionRequestBinding(),
    ),

    // --- ADOPTION STATUS PAGE ---
    GetPage(
      name: AppRoutes.adoptionStatus,
      page: () => const AdoptionStatusView(),
      binding: AdoptionStatusBinding(),
    ),

    // --- FOLLOWING PAGE ---
    GetPage(
      name: '/following',
      page: () => const FollowingView(),
      binding: FollowingBinding(),
    ),

    // --- VERIFICATION PAGE ---
    GetPage(
      name: AppRoutes.verification,
      page: () => const VerificationView(),
      binding: VerificationBinding(),
    ),

    // --- SHELTER HOME PAGE (with Bottom Nav) ---
    GetPage(
      name: AppRoutes.shelterHome,
      page: () => const ShelterNavigationView(),
      binding: ShelterNavigationBinding(),
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

    // --- SHELTER MANAGE PETS PAGE ---
    GetPage(
      name: AppRoutes.shelterManagePets,
      page: () => const ManagePetsView(),
      binding: ManagePetsBinding(),
    ),

    // --- SHELTER MANAGE EVENTS PAGE ---
    GetPage(
      name: AppRoutes.shelterManageEvents,
      page: () => const ManageEventsView(),
      binding: ManageEventsBinding(),
    ),

    // --- SHELTER EDIT PET PAGE ---
    GetPage(
      name: AppRoutes.shelterEditPet,
      page: () => const EditPetView(),
      binding: EditPetBinding(),
    ),

    // --- SHELTER EDIT EVENT PAGE ---
    GetPage(
      name: AppRoutes.shelterEditEvent,
      page: () => const EditEventView(),
      binding: EditEventBinding(),
    ),

    // --- EDIT SHELTER PROFILE PAGE ---
    GetPage(
      name: AppRoutes.editShelterProfile,
      page: () => const EditShelterProfileView(),
      binding: EditShelterProfileBinding(),
    ),

    // --- SHELTER PROFILE PAGE ---
    GetPage(
      name: AppRoutes.shelterProfile,
      page: () => const ShelterProfileView(),
      binding: ShelterProfileBinding(),
    ),

    // --- SHELTER ADOPTION MANAGEMENT PAGE ---
    GetPage(
      name: AppRoutes.shelterAdoptionManagement,
      page: () => const ShelterAdoptionManagementView(),
      binding: ShelterAdoptionManagementBinding(),
    ),

    // --- SHELTER FOLLOWERS PAGE ---
    GetPage(
      name: '/shelter/followers',
      page: () => const FollowersView(),
      binding: FollowersBinding(),
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

    // --- SUSPENDED ACCOUNT PAGE ---
    GetPage(
      name: AppRoutes.suspendedAccount,
      page: () => const SuspendedAccountView(),
      binding: SuspendedAccountBinding(),
    ),
  ];
}
