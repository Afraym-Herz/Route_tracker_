import 'package:flutter/material.dart';

class customTextField extends StatelessWidget {
  const customTextField({super.key, required this.textEditingController});
  
  final TextEditingController textEditingController ;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textEditingController,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
        hintText: "Search Here",
        fillColor: Colors.white,
        filled: true,
        border: buildBorder(),
        enabledBorder: buildBorder(),
        focusedBorder: buildBorder(),
      ),
    );
  }

  OutlineInputBorder buildBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide(color: Colors.transparent),
    );
  }
}