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

  Future<List<Cookie>> getAllCookies() async {
    List<Cookie> cookies = await cookieManager.getCookies(url: url);

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
