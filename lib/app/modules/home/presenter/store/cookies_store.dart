import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class CookiesStore {
  CookieManager cookieManager = CookieManager.instance();

  final expiresDate =
      DateTime.now().add(const Duration(days: 3)).millisecondsSinceEpoch;
  final url = WebUri("https://flutter.dev/");
  final String domain = ".flutter.dev";

  void setCookie({required String value, required String name}) async {
    await cookieManager.setCookie(
      url: url,
      name: name,
      value: value,
      expiresDate: expiresDate,
      isSecure: true,
    );
  }

  Future<List<Cookie>> getAllCookies({required BuildContext context}) async {
    List<Cookie> cookies = await cookieManager.getCookies(url: url);

    // print(cookies[1]);

    final snackBar = SnackBar(
      content: Text(
          '${cookies[0].name}: ${cookies[0].value}, ${cookies[1].name}: ${cookies[1].value}'),
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    return cookies;
  }

  Future<Cookie?> getCookie(
      {required String name, required BuildContext context}) async {
    Cookie? cookie = await cookieManager.getCookie(url: url, name: name);

    final snackBar = SnackBar(
      content: Text(cookie!.value),
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    return cookie;
  }

  void deleteCookie({required String name}) async {
    await cookieManager.deleteCookie(url: url, name: name);
  }

  void deleteAllCookies() async {
    await cookieManager.deleteCookies(url: url, domain: domain);
  }
}
