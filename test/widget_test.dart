import 'package:flutter_test/flutter_test.dart';
import 'package:basic_calculator_logic/calculator_ui.dart';

void main() {
  testWidgets('Calculator UI loads and converter button is visible', (WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorApp());

    expect(find.text('Калькулятор'), findsOneWidget);

    expect(find.text('Конвертация: км в мили'), findsOneWidget);
  });
}