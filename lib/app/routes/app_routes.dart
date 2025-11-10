abstract class AppRoutes {
  AppRoutes._();
  static const splash = _Paths.splash;
  static const starter = _Paths.starter;
  static const login = _Paths.login;
  static const register = _Paths.register;
  static const userHome = _Paths.userHome;
  static const adopt = _Paths.adopt;
  static const event = _Paths.event;
  static const chat = _Paths.chat;
  static const profile = _Paths.profile;
  static const verification = _Paths.verification;
  static const shelterHome = _Paths.shelterHome;
  static const shelterAddPet = _Paths.shelterAddPet;
  static const shelterAddEvent = _Paths.shelterAddEvent;
  static const adminHome = _Paths.adminHome;
  static const adminUserManagement = _Paths.adminUserManagement;
  static const adminShelterVerification = _Paths.adminShelterVerification;
}

abstract class _Paths {
  _Paths._();
  static const splash = '/splash';
  static const starter = '/starter';
  static const login = '/login';
  static const register = '/register';
  static const userHome = '/user-home';
  static const adopt = '/adopt';
  static const event = '/event';
  static const chat = '/chat';
  static const profile = '/profile';
  static const verification = '/verification';
  static const shelterHome = '/shelter-home';
  static const shelterAddPet = '/shelter/add-pet';
  static const shelterAddEvent = '/shelter/add-event';
  static const adminHome = '/admin-home';
  static const adminUserManagement = '/admin/user-management';
  static const adminShelterVerification = '/admin/shelter-verification';
}
