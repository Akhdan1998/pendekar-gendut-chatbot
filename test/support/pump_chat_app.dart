import 'package:ai_chatbot/features/chat/controllers/chat_controller.dart';
import 'package:ai_chatbot/main.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpChatApp(
  WidgetTester tester, {
  ChatController? controller,
}) async {
  tester.binding.platformDispatcher.defaultRouteNameTestValue = '/chat';
  addTearDown(tester.binding.platformDispatcher.clearDefaultRouteNameTestValue);
  await tester.pumpWidget(MyApp(controller: controller));
}
