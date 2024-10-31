import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:innap_webview_study/app/modules/home/presenter/store/cookies_store.dart';
import 'package:innap_webview_study/app/modules/home/presenter/store/home_store.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey webViewKey = GlobalKey();

  final HomeStore store = HomeStore();
  final CookiesStore cookiesStore = CookiesStore();

  @override
  void initState() {
    store.setPullToRefreshController();
    store.setContextMenu(context);
    super.initState();
  }

  @override
  void dispose() {
    store.printJobController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        store.webViewController?.goBack();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: store.canGoBack
              ? IconButton(
                  onPressed: () {
                    store.webViewController?.goBack();
                  },
                  icon: const Icon(Icons.arrow_back_ios))
              : null,
          actions: [
            IconButton(
                onPressed: () {
                  store.printDocument(context: context);
                },
                icon: const Icon(Icons.print))
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              InAppWebView(
                key: webViewKey,
                initialUrlRequest:
                    URLRequest(url: WebUri('https://github.com/flutter/')),
                contextMenu: store.contextMenu,
                initialSettings: store.settings,
                pullToRefreshController: store.pullToRefreshController,
                onWebViewCreated: (controller) {
                  store.setWebViewController(controller: controller);
                },
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  return NavigationActionPolicy.ALLOW;
                },
                onLoadStart: (controller, url) {
                  if (url.toString() != "https://github.com/flutter/") {
                    store.canGoBack = true;
                  } else {
                    store.canGoBack = false;
                  }
                },
                onLoadStop: (controller, url) async {
                  store.pullToRefreshController?.endRefreshing();
                  await controller.injectJavascriptFileFromAsset(
                      assetFilePath: "assets/js/main.js");
                },
                onReceivedError: (controller, request, error) {
                  store.pullToRefreshController?.endRefreshing();
                },
                onProgressChanged: (controller, progress) {
                  if (progress == 100) {
                    store.pullToRefreshController?.endRefreshing();
                  }
                  setState(() {
                    store.progress = progress / 100;
                  });
                },
              ),
              store.progress < 1.0
                  ? LinearProgressIndicator(
                      value: store.progress,
                    )
                  : Container(),
              store.progress < 1.0
                  ? Container(
                      color: Colors.white.withOpacity(0.5),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(items: [
          BottomNavigationBarItem(
              label: 'save',
              icon: IconButton(
                  onPressed: () {
                    cookiesStore.setCookie(value: 'value23', name: 'name4');
                  },
                  icon: const Icon(Icons.save))),
          BottomNavigationBarItem(
              label: 'get',
              icon: IconButton(
                  onPressed: () {
                    cookiesStore.getCookie(name: 'name4', context: context);
                  },
                  icon: const Icon(Icons.remove_red_eye_outlined))),
          BottomNavigationBarItem(
              label: 'getAll',
              icon: IconButton(
                  onPressed: () {
                    cookiesStore.getAllCookies(context: context);
                  },
                  icon: const Icon(Icons.remove_red_eye_outlined)))
        ]),
      ),
    );
  }
}
