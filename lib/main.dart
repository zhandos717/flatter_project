import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'country.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: MyWidget(),
      ),
    );
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({Key? key});

  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  List<Country> countries = [
    Country('Russia', const LatLng(55.7558, 37.6176)),
  ];

  int currentQuestionIndex = 0;
  int correctAnswers = 0;

  // Контроллер для масштабирования карты
  final MapController mapController = MapController();

  bool isAnswerCorrect(bool userAnswer) {
    final String expectedCountryName = countries[currentQuestionIndex].name;

    // Сравниваем ответ пользователя с ожидаемым названием страны
    return userAnswer ==
        (expectedCountryName == 'Russia'); // Пример сравнения с 'Russia'
  }

  void nextQuestion() async {
    try {
      final List<Country> fetchedCountries = await fetchCountries();
      setState(() {
        countries = fetchedCountries;
        currentQuestionIndex = 0;
        correctAnswers = 0;
        mapController.move(countries[currentQuestionIndex].coordinates, 4.0);
      });
    } catch (e) {
      // Обработка ошибки при загрузке данных
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          child: FlutterMap(
            options: MapOptions(
              center: countries[currentQuestionIndex].coordinates,
              zoom: 4.0,
            ),
            mapController: mapController,
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: countries[currentQuestionIndex].coordinates,
                    builder: (ctx) => Container(
                      child: const Icon(
                        Icons.location_on,
                        size: 40.0,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Text('Is this ${countries[currentQuestionIndex].name}?'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                // Проверка ответа
                if (isAnswerCorrect(true)) {
                  // Если ответ правильный, увеличьте счет
                  setState(() {
                    correctAnswers++;
                  });
                }

                // Переключение на следующий вопрос
                nextQuestion();
              },
              child: Text('Yes'),
            ),
            ElevatedButton(
              onPressed: () {
                // Проверка ответа
                if (isAnswerCorrect(false)) {
                  // Если ответ правильный, увеличьте счет
                  setState(() {
                    correctAnswers++;
                  });
                }

                // Переключение на следующий вопрос
                nextQuestion();
              },
              child: Text('No'),
            ),
          ],
        ),
      ],
    );
  }
}
