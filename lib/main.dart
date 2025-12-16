import 'package:flutter/material.dart';
import 'app.dart';

void main() {
  runApp(const App(
    // Set to true for real-time streaming updates
    // Set to false for one-time data loading (better for development)
    useStreaming: false,

    // You can also pass a custom repository:
    // repository: ApiInventoryRepository(baseUrl: 'https://api.example.com'),
  ));
}
