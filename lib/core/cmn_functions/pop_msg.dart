import 'package:flutter/material.dart';

showMsg(BuildContext context, {required String text}){
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
        content: Text(text)
    )
  );
}