class DivideByZeroException implements Exception {
  final String message;
  DivideByZeroException([this.message = 'Деление на ноль']);

  @override
  String toString() => message;
}

class CalculatorModel {
  double calculate(double a, double b, String operator) {
    switch (operator) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case 'x':
        return a * b;
      case '/':
        if (b == 0) throw DivideByZeroException();  // выбрасывание исключения при делении на ноль
        return a / b;
      default:
        throw FormatException("Неизвестный оператор");
    }
  }
}
