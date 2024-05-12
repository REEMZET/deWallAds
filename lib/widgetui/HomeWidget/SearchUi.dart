import 'package:flutter/material.dart';

Widget buildSearchWidget(Function(String) onTextChanged) {
  return Padding(
    padding: const EdgeInsets.only(left: 30, right: 30, top: 15),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: Row(
          children: <Widget>[
            const Icon(
              Icons.search,
              color: Colors.grey,
              size: 15,
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: TextField(
                style: const TextStyle(fontSize: 10),
                decoration: const InputDecoration(
                  hintText: "Search location...",
                  border: InputBorder.none,
                ),
                onChanged: onTextChanged, // Callback when the text changes
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
