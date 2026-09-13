import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharma_way/presentation/widgets/quantity_selector.dart';

void main() {
  testWidgets(
    'the quantity field confirms the value and dismisses the keyboard',
    (tester) async {
      final controller = TextEditingController(text: '1');
      var selectedQuantity = 1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuantitySelector(
              quantity: selectedQuantity,
              stockQuantity: 20,
              quantityController: controller,
              onQuantityChanged: (quantity) => selectedQuantity = quantity,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.enterText(find.byType(TextField), '4');
      await tester.tap(find.byIcon(Icons.check));
      await tester.pump();

      expect(selectedQuantity, 4);
      expect(
        tester
            .widget<EditableText>(find.byType(EditableText))
            .focusNode
            .hasFocus,
        isFalse,
      );
    },
  );
}
