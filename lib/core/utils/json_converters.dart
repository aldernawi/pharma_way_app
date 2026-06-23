class JsonConverters {
  // --- String to Int ---
  static int? parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      if (value.isEmpty) return null;
      // Handle "1.0" or "1"
      return int.tryParse(value) ?? double.tryParse(value)?.toInt();
    }
    return null;
  }

  static int toInt(dynamic value) {
    return parseInt(value) ?? 0;
  }

  // --- String to Double ---
  static double? parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      if (value.isEmpty) return null;
      return double.tryParse(value);
    }
    return null;
  }

  static double buildDouble(dynamic value) {
    return parseDouble(value) ?? 0.0;
  }
  
  // --- String/Int to Bool ---
  static bool? parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    
    if (value is int) {
      return value == 1;
    }
    
    if (value is String) {
      final v = value.toLowerCase();
      return v == 'true' || v == '1' || v == 'yes';
    }
    
    return null;
  }
  
  static bool toBool(dynamic value) {
    return parseBool(value) ?? false;
  }

  // --- String Handling ---
  static String? parseString(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }
  
  static String buildString(dynamic value) {
    return parseString(value) ?? '';
  }
}
