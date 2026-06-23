import 'package:flutter/foundation.dart';

class ApiHelper {
  // Helper to safely extract list from response
  // supporting: 
  // - List<dynamic>
  // - { "data": [...] }
  // - { "data": { "data": [...] } } (pagination)
  // - { "products": [...] } etc.
  static List<T> extractList<T>(
    dynamic responseData, 
    T Function(Map<String, dynamic>) fromJson
  ) {
    List<dynamic> rawList = [];
    
    try {
      if (responseData is List) {
        rawList = responseData;
      } else if (responseData is Map) {
        if (responseData.containsKey('data')) {
          final data = responseData['data'];
          if (data is List) {
            // Standard resource collection
            rawList = data;
          } else if (data is Map && data.containsKey('data') && data['data'] is List) {
            // Paginated resource
            rawList = data['data'];
          }
        } else if (responseData.containsKey('products') && responseData['products'] is List) {
          rawList = responseData['products'];
        } else if (responseData.containsKey('orders') && responseData['orders'] is List) {
          rawList = responseData['orders'];
        }
      }
    } catch (e) {
      debugPrint('ApiHelper Error extracting list: $e');
      return [];
    }
    
    // Safely map each item
    return rawList.map((item) {
      try {
        if (item is Map<String, dynamic>) {
          return fromJson(item);
        } else {
           // If item isn't a map (e.g. String or null), ignore or handle
           // Depending on T, this might crash if we force it. 
           // But typical usage assumes T is a Model.
           debugPrint('ApiHelper Warning: Item is not a Map: $item');
           return null;
        }
      } catch (e) {
        debugPrint('ApiHelper Error parsing item: $e, Item: $item');
        return null;
      }
    }).where((item) => item != null).cast<T>().toList();
  }

  // Helper to safely extract single object data
  static T? extractData<T>(
    dynamic responseData, 
    T Function(Map<String, dynamic>) fromJson
  ) {
    try {
      Map<String, dynamic>? dataMap;

      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>) {
          dataMap = responseData['data'];
        } else {
          // Maybe the response itself is the object
          dataMap = responseData;
        }
      }
      
      if (dataMap != null) {
        return fromJson(dataMap);
      }
    } catch (e) {
      debugPrint('ApiHelper Error extracting data: $e');
    }
    
    return null;
  }
}
