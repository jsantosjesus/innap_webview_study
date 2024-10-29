import 'package:flutter/material.dart';

showSnackBar(
    {required BuildContext context,
    required String mesage,
    bool isError = true}) {
  SnackBar snackBar = SnackBar(
      content: Text(
        mesage,
        style: const TextStyle(),
      ),
      backgroundColor: (isError) ? Colors.red : Colors.green);

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
