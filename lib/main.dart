import 'package:flutter/material.dart';

const Color darkBlue = Color.fromARGB(255, 18, 32, 47);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: MyWidget(),
        ),
      ),
    );
  }
}

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Flexible(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('Is it Astana ?', style: TextStyle(fontSize: 32)),
            Text('Kazakhstan'),
          ],
        ),
      ),
      Flexible(
        flex: 4,
        child: SizedBox.expand(
          child: Container(
            child: Padding(
              padding: EdgeInsets.all(100.5),
              child: Card(
                elevation: 12.0,
                child: Container(
                  width: 300,
                  height: 300,
                  child: Text('Kazakhstan'),
                ),
              ),
            ),
          ),
        ),
      ),
      Flexible(
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextButton(child: const Text('True'), onPressed: () {}),
              TextButton(child: const Text('Yes'), onPressed: () {}),
            ],
          ),
        ),
      ),
    ]);
  }
}
