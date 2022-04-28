import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';

void onSafeBrowsingHit() {
  final shouldSkip = kIsWeb ||
      ![
        TargetPlatform.android,
      ].contains(defaultTargetPlatform);

  testWidgets('onSafeBrowsingHit', (WidgetTester tester) async {
    final Completer<String> pageLoaded = Completer<String>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(
              url: TEST_CHROME_SAFE_BROWSING_MALWARE),
          initialSettings: InAppWebViewSettings(
            // if I set javaScriptEnabled to true, it will crash!
            javaScriptEnabled: false,
            clearCache: true,
            safeBrowsingEnabled: true,
          ),
          onWebViewCreated: (controller) {
            controller.startSafeBrowsing();
          },
          onLoadStop: (controller, url) {
            pageLoaded.complete(url!.toString());
          },
          onSafeBrowsingHit: (controller, url, threatType) async {
            return SafeBrowsingResponse(
                report: true, action: SafeBrowsingResponseAction.PROCEED);
          },
        ),
      ),
    );

    final String url = await pageLoaded.future;
    expect(url, TEST_CHROME_SAFE_BROWSING_MALWARE.toString());
  }, skip: shouldSkip);
}
