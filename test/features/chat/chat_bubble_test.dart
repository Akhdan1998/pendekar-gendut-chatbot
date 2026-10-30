import 'package:ai_chatbot/core/theme/app_theme.dart';
import 'package:ai_chatbot/features/chat/models/chat_message.dart';
import 'package:ai_chatbot/features/chat/widgets/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('assistant formats bold, lists, paragraphs and line breaks', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(
          body: SingleChildScrollView(
            child: ChatBubble(
              message: ChatMessage(
                role: ChatRole.assistant,
                content:
                    '**Beras Ramos**\n\n- Beras\n- Gula\n\n'
                    '1. Pilih produk\n2. Bayar\n\n'
                    'Baris satu\nBaris dua  \nBaris tiga',
                responseTimeMs: 1250,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Beras Ramos', findRichText: true), findsWidgets);
    expect(find.text('Beras', findRichText: true), findsWidgets);
    expect(find.text('Gula', findRichText: true), findsWidgets);
    expect(find.text('1.', findRichText: true), findsWidgets);
    expect(find.text('2.', findRichText: true), findsWidgets);
    var bold = false;
    final rendered = <String>[];
    for (final text in tester.widgetList<SelectableText>(
      find.byType(SelectableText),
    )) {
      rendered.add(text.data ?? text.textSpan!.toPlainText());
      text.textSpan?.visitChildren((span) {
        if (span.toPlainText() == 'Beras Ramos' &&
            span.style?.fontWeight == FontWeight.bold) {
          bold = true;
        }
        return true;
      });
    }
    expect(bold, isTrue);
    expect(rendered, contains('Baris satu\nBaris dua\nBaris tiga'));
    expect(find.text('Waktu respons: 1.3 detik'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('user Markdown remains literal selectable text', (tester) async {
    const message = '**tebal**\n- daftar\n1. satu';
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(
          body: ChatBubble(
            message: ChatMessage(role: ChatRole.user, content: message),
          ),
        ),
      ),
    );
    expect(
      tester.widget<SelectableText>(find.byType(SelectableText)).data,
      message,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  for (final width in [320.0, 900.0, 1440.0]) {
    testWidgets('long assistant Markdown wraps within $width pixels', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ChatBubble(
                  message: ChatMessage(
                    role: ChatRole.assistant,
                    content:
                        '**Daftar produk**\n\n${List.filled(40, '- Informasi produk yang panjang dan tetap terbaca.').join('\n')}\n\n${'Ramos' * 100}',
                    responseTimeMs: 2000,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      final texts = find.descendant(
        of: find.byType(ChatBubble),
        matching: find.byType(SelectableText),
      );
      for (final element in texts.evaluate()) {
        final rect = tester.getRect(
          find.byElementPredicate((other) => other == element),
        );
        expect(rect.left, greaterThanOrEqualTo(20));
        expect(rect.right, lessThanOrEqualTo(width - 20));
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
