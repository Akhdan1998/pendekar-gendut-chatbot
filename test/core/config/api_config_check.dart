import 'package:ai_chatbot/core/config/api_config.dart';

// Run with --enable-asserts and the expected URL as the sole argument.
void main(List<String> arguments) {
  assert(ApiConfig.baseUrl == arguments.single, ApiConfig.baseUrl);
}
