import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:innap_webview_study/app/modules/home/presenter/store/cookies_store.dart';
import 'package:innap_webview_study/app/modules/home/presenter/store/find_interaction_store.dart';
import 'package:innap_webview_study/app/modules/home/presenter/store/home_store.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey webViewKey = GlobalKey();
  final searchController = TextEditingController();

  final HomeStore store = HomeStore();
  final CookiesStore cookiesStore = CookiesStore();
  final FindInteractionStore findInteractionStore = FindInteractionStore();

  @override
  void initState() {
    store.setPullToRefreshController();
    findInteractionStore.setFindInteraction(context: context);
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
    var isFindInteractionEnabled =
        store.settings.isFindInteractionEnabled ?? false;
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
                icon: const Icon(Icons.print)),
            ValueListenableBuilder(
                valueListenable: findInteractionStore.search,
                builder: ((context, search, _) {
                  return IconButton(
                      onPressed: () {
                        findInteractionStore.setSearch(
                            value: !findInteractionStore.search.value);
                        searchController.text = '';
                      },
                      icon:
                          Icon(!search ? Icons.search : Icons.cancel_outlined));
                }))
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              InAppWebView(
                key: webViewKey,
                findInteractionController:
                    findInteractionStore.findInteractionController,
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
              AnimatedBuilder(
                  animation: Listenable.merge([
                    findInteractionStore.textFound,
                    findInteractionStore.search
                  ]),
                  builder: ((context, child) {
                    if (!isFindInteractionEnabled &&
                        findInteractionStore.search.value) {
                      return TextField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.search),
                          suffixText: findInteractionStore.textFound.value,
                          suffixIcon: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const SizedBox(
                                width: 10,
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_upward),
                                onPressed: () {
                                  findInteractionStore
                                      .findInteractionController!
                                      .findNext(forward: false);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_downward),
                                onPressed: () {
                                  findInteractionStore
                                      .findInteractionController!
                                      .findNext();
                                },
                              ),
                            ],
                          ),
                        ),
                        controller: searchController,
                        keyboardType: TextInputType.text,
                        onSubmitted: (value) {
                          if (value == '') {
                            findInteractionStore.findInteractionController!
                                .clearMatches();
                            findInteractionStore.setTextFound(text: '');
                          } else {
                            findInteractionStore.findInteractionController!
                                .findAll(find: value);
                          }
                        },
                      );
                    } else {
                      return Container();
                    }
                  })),
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
