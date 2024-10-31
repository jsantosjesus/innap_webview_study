import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:innap_webview_study/app/utils/snack/snack.dart';

class HomeStore {
  // final ValueNotifier<String> successOrErrorPrint = ValueNotifier<String>('');

  ContextMenu? contextMenu;
  PrintJobController? printJobController;
  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
      isInspectable: false,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllowFullscreen: true);

  PullToRefreshController? pullToRefreshController;
  double progress = 0;
  bool canGoBack = false;

  void setWebViewController({required InAppWebViewController controller}) {
    webViewController = controller;
  }

  void setPullToRefreshController() {
    pullToRefreshController = kIsWeb ||
            ![TargetPlatform.iOS, TargetPlatform.android]
                .contains(defaultTargetPlatform)
        ? null
        : PullToRefreshController(
            settings: PullToRefreshSettings(
              color: Colors.blue,
            ),
            onRefresh: reload,
          );
  }

  void reload() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      webViewController?.reload();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      webViewController?.loadUrl(
          urlRequest: URLRequest(url: await webViewController?.getUrl()));
    }
  }

  void printDocument({required BuildContext context}) async {
    printJobController?.dispose();

    final jobSettings = PrintJobSettings(
        handledByClient: true,
        jobName: "${await webViewController?.getTitle() ?? ''} - PDF Document",
        colorMode: PrintJobColorMode.MONOCHROME,
        outputType: PrintJobOutputType.GRAYSCALE,
        // orientation: defaultTargetPlatform == TargetPlatform.iOS
        //     ? PrintJobOrientation.LANDSCAPE
        //     : null,
        numberOfPages: 1);

    printJobController =
        await webViewController?.printCurrentPage(settings: jobSettings);

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      printJobController?.onComplete = (completed, error) async {
        if (completed) {
          showSnackBar(context: context, mesage: 'Sucesso ao imprimir');
        } else {
          showSnackBar(context: context, mesage: 'Sucesso ao imprimir');
        }
        printJobController?.dispose();
      };
    }

    // final jobInfo = await printJobController?.getInfo();
    // print(jobInfo);
  }

  void setContextMenu(BuildContext context) {
    contextMenu = ContextMenu(
        menuItems: [
          ContextMenuItem(
              id: 1,
              title: "Special",
              action: () async {
                const snackBar = SnackBar(
                  content: Text("Special clicked!"),
                  duration: Duration(seconds: 1),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              })
        ],
        onCreateContextMenu: (hitTestResult) async {
          String selectedText =
              await webViewController?.getSelectedText() ?? "";
          final snackBar = SnackBar(
            content: Text(
                "Selected text: '$selectedText', of type: ${hitTestResult.type.toString()}"),
            duration: const Duration(seconds: 1),
          );
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
        onContextMenuActionItemClicked: (menuItem) {
          final snackBar = SnackBar(
            content: Text(
                "Menu item with ID ${menuItem.id} and title '${menuItem.title}' clicked!"),
            duration: const Duration(seconds: 1),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        });
  }
}
