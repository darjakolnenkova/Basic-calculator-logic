import 'package:flutter/material.dart';
import 'km_to_mile_converter.dart';
import 'calculator_model.dart';
import 'controller.dart';

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Калькулятор',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CalculatorUI(),
    );
  }
}

class CalculatorUI extends StatefulWidget {
  const CalculatorUI({Key? key}) : super(key: key);

  @override
  _CalculatorUIState createState() => _CalculatorUIState();
}

class DivideByZeroException implements Exception {
  final String message;
  DivideByZeroException([this.message = 'Деление на ноль']);

  @override
  String toString() => message;
}

class _CalculatorUIState extends State<CalculatorUI> {
  String display = '0';   // текущий текст
  final CalculatorModel model = CalculatorModel();  // подключение модели
  late KmMileConverterController controller;         // контроллер для другой страницы

  final List<String> buttons = const [    // список кнопок
    '7', '8', '9', '/',
    '4', '5', '6', 'x',
    '1', '2', '3', '-',
    'C', '0', '=', '+',
  ];

  @override
  void initState() {
    super.initState();
    controller = KmMileConverterController();
  }

  void buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'C') {
        display = '0';  // сброс отображения
      } else if (buttonText == '=') {
        try {
          final result = _evaluate(display); // вычисление результата

          if (result % 1 == 0) {
            // если результат целый (остаток от деления на 1 == 0)
            display = result.toInt().toString();
          } else {
            // если результат дробный — округляем до 8 знаков и убираем лишние нули
            String formatted = result.toStringAsFixed(8);
            formatted = formatted.replaceFirst(RegExp(r'\.?0+$'), ''); // убираем лишние нули и точку
            display = formatted;
          }
        } catch (e) {
          if (e is FormatException) {
            display = e.message;  // сообщение об ошибке формата
          } else if (e is DivideByZeroException) {
            display = e.message;  // сообщение о делении на ноль
          } else {
            display = "Ошибка";  // для других ошибок
          }
        }
      } else {
        display = display == '0' ? buttonText : display + buttonText;  // обновление строки
      }
    });
  }

  double _evaluate(String expression) {
    // проверяем, что выражение не заканчивается на оператор
    if (expression.endsWith('+') ||
        expression.endsWith('-') ||
        expression.endsWith('x') ||
        expression.endsWith('/')) {
      throw FormatException("Неверный формат");
    }

    for (var op in ['+', '-', 'x', '/']) {
      if (expression.contains(op)) {
        final parts = expression.split(op);
        if (parts.length != 2) throw FormatException("Неверный формат");

        try {
          final a = double.parse(parts[0]);
          final b = double.parse(parts[1]);

          if (op == '/' && b == 0) {
            throw DivideByZeroException();
          }

          return model.calculate(a, b, op);
        } on DivideByZeroException catch (_) {
          rethrow; // пробрасываем исключение деления на ноль
        } on FormatException catch (_) {
          rethrow; // пробрасываем исключение формата
        } catch (_) {
          throw FormatException("Ошибка");  // другие ошибки
        }
      }
    }
    throw FormatException("Оператор не найден");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Калькулятор')),     // панель с названием
      body: SingleChildScrollView(                        // основная часть экрана
        child: Column(
          children: [
            SizedBox(      // блок с введенным выражением или результатом
              height: MediaQuery.of(context).size.height * 0.3,
              child: Container(
                alignment: Alignment.bottomRight,   // выравнивание по правому краю
                padding: const EdgeInsets.all(24),   // отступы внутри контейнера
                child: Text(
                  display,     // показывает текущее значение
                  style: const TextStyle(fontSize: 56),
                ),
              ),
            ),
            GridView.builder(    // сетка с кнопками
              shrinkWrap: true,     // -- размер подстраивается под содержимое
              physics: const NeverScrollableScrollPhysics(),  // без прокрутки
              itemCount: buttons.length,   // кол-во кнопок
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),  // 4 кнопки в ряд
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8),  // отступы между кнопками
                  child: ElevatedButton(
                    onPressed: () => buttonPressed(buttons[index]),   // обработка нажатия
                    child: Text(
                      buttons[index],   // текст на кнопке
                      style: const TextStyle(fontSize: 35),   // размер текста
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),    // отступ перед кнопкой км в мили
            ElevatedButton(             // кнопка перехода на экран км в мили
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const KmToMileConverterScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),  // размер кнопки
                textStyle: const TextStyle(fontSize: 20),       // размер текста
              ),
              child: const Text('Конвертация: км в мили'),   // текст на кнопке
            ),
            const SizedBox(height: 20),   // отступ внизу
          ],
        ),
      ),
    );
  }
}