abstract class AppRoutes {
  AppRoutes._();
  
  static const starter = _Paths.starter;
  static const login = _Paths.login;
  static const register = _Paths.register;
  // Tambahkan rute lain di sini
}

abstract class _Paths {
  _Paths._();
  static const starter = '/starter';
  static const login = '/login';
  static const register = '/register';
}
