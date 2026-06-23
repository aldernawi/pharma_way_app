// Quick fix script to remove json_annotation dependencies from all models
// This is a temporary solution until build_runner issues are resolved
// ignore_for_file: avoid_print

import 'dart:io';

void main() {
  print('Fixing model files...');
  
  final modelsPath = 'lib/data/models';
  final files = [
    'company_model.dart',
    'advertisement_model.dart', 
    'brand_model.dart',
    'product_model.dart',
    'cart_model.dart',
    'order_model.dart',
  ];
  
  for (var fileName in files) {
    final file = File('$modelsPath/$fileName');
    if (file.existsSync()) {
      var content = file.readAsStringSync();
      
      // Remove json_annotation import
      content = content.replaceAll("import 'package:json_annotation/json_annotation.dart';\n", '');
      
      // Remove part directive
      content = content.replaceAll(RegExp(r"part '[^']+\.g\.dart';\n"), '');
      
      // Remove @JsonSerializable() annotations
      content = content.replaceAll('@JsonSerializable()\n', '');
      content = content.replaceAll('@JsonSerializable()', '');
      
      // Remove @JsonKey annotations (simple cases)
      content = content.replaceAll(RegExp(r"@JsonKey\([^)]+\)\s*"), '');
      
      file.writeAsStringSync(content);
      print('Fixed: $fileName');
    }
  }
  
  print('Done! Models fixed. You may need to implement fromJson/toJson manually.');
  print('Run: flutter run -d chrome');
}
