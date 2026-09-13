import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharma_way/core/utils/responsive_layout.dart';

void main() {
  test('uses a phone grid below the tablet breakpoint', () {
    expect(ResponsiveLayout.gridColumnsFor(const Size(390, 844)), 2);
  });

  test('uses three columns on a portrait iPad', () {
    expect(ResponsiveLayout.gridColumnsFor(const Size(768, 1024)), 3);
  });

  test('uses four columns on a landscape iPad', () {
    expect(ResponsiveLayout.gridColumnsFor(const Size(1024, 768)), 4);
  });
}
