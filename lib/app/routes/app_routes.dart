abstract class AppRoutes {
  AppRoutes._();
  
  // Halaman awal kita ubah ke splash
  static const splash = _Paths.splash;
  static const starter = _Paths.starter;
  static const login = _Paths.login;
  static const register = _Paths.register;

  // Rute untuk setiap role
  static const userHome = _Paths.userHome;
  // static const shelterHome = _Paths.shelterHome;
  // static const adminHome = _Paths.adminHome;
}

abstract class _Paths {
  _Paths._();
  static const splash = '/splash';
  static const starter = '/starter';
  static const login = '/login';
  static const register = '/register';

  static const userHome = '/user-home';
  // static const shelterHome = '/shelter-home';
  // static const adminHome = '/admin-home';
}