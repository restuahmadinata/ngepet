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
}