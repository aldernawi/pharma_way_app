// Simple script to generate .g.dart files for models
// Run with: dart run generate_models.dart
// ignore_for_file: avoid_print

import 'dart:io';

void main() {
  print('Generating model files...');
  
  // Create empty .g.dart files to satisfy imports
  final models = [
    'user_model',
    'company_model',
    'advertisement_model',
    'brand_model',
    'product_model',
    'cart_model',
    'order_model',
  ];
  
  final libPath = 'lib/data/models';
  
  for (var model in models) {
    final file = File('$libPath/$model.g.dart');
    if (!file.existsSync()) {
      file.writeAsStringSync('''
// GENERATED CODE - DO NOT MODIFY BY HAND
// This is a placeholder file for $model

part of '$model.dart';

// Placeholder - models use manual JSON serialization
''');
      print('Created $model.g.dart');
    }
  }
  
  print('Done! All model files generated.');
}
