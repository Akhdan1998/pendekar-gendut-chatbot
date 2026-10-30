class ApiConfig {
  ApiConfig._();

  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: bool.fromEnvironment('dart.vm.product')
        ? 'https://umkm-chatbot-backend-sgtx.vercel.app'
        : 'http://127.0.0.1:8000',
  );
  static const connectTimeout = Duration(seconds: 10);
  static const sendTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 60);
  static const historyLimit = 10;
}
