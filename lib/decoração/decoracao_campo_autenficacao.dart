import 'package:flutter/material.dart';

InputDecoration getAuthenticationInputDecoration(String label){
  return InputDecoration(
    hintText: label,
    fillColor: const Color.fromARGB(255, 178, 178, 178),
    filled: true,
    contentPadding: const EdgeInsets.fromLTRB(16, 8, 16,8),

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(64)
    ),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(64),
      borderSide: const BorderSide(color: Colors.black, width: 2),
    ),
    
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(64),
      borderSide: const BorderSide(color: Color.fromARGB(255, 64, 64, 64), width: 4),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(64),
      borderSide: const BorderSide(color: Colors.red, width: 2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(64),
      borderSide: const BorderSide(color: Colors.red, width: 3),
    ),

  );
}