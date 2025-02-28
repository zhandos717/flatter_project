import 'package:flutter/material.dart';

class ColorPickerWidget extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;

  const ColorPickerWidget({
    Key? key,
    required this.initialColor,
    required this.onColorChanged,
  }) : super(key: key);

  @override
  _ColorPickerWidgetState createState() => _ColorPickerWidgetState();
}

class _ColorPickerWidgetState extends State<ColorPickerWidget> {
  late Color _selectedColor;

  // Predefined color palette
  final List<Color> _colorPalette = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Показываем текущий выбранный цвет
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Выбранный цвет: ${_getHexColor(_selectedColor)}',
                    style: TextStyle(
                      color: _selectedColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Сетка цветов
              SizedBox(
                height: 200, // Фиксированная высота
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _colorPalette.length,
                  itemBuilder: (context, index) {
                    final color = _colorPalette[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                        });
                        widget.onColorChanged(color);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(10),
                          border: _selectedColor == color
                              ? Border.all(
                            color: Colors.white,
                            width: 3,
                            strokeAlign: BorderSide.strokeAlignOutside,
                          )
                              : null,
                          boxShadow: _selectedColor == color
                              ? [
                            BoxShadow(
                              color: color.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                            )
                          ]
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              // Возможность ручного ввода HEX
              TextField(
                decoration: InputDecoration(
                  labelText: 'Или введите HEX цвет',
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    width: 24,
                    height: 24,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  try {
                    // Validate and parse HEX color
                    final color = _parseHexColor(value);
                    setState(() {
                      _selectedColor = color;
                    });
                    widget.onColorChanged(color);
                  } catch (e) {
                    // Optionally handle invalid color input
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Utility method to convert color to HEX string
  String _getHexColor(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  // Utility method to parse HEX color
  Color _parseHexColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 3) {
      hexColor = hexColor.split('').map((char) => char * 2).join();
    }
    return Color(int.parse('0xFF$hexColor'));
  }
}

// Usage in dialog or form
class ColorPickerDialog extends StatefulWidget {
  final Color initialColor;

  const ColorPickerDialog({
    Key? key,
    required this.initialColor
  }) : super(key: key);

  @override
  _ColorPickerDialogState createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Выбор цвета'),
      content: SizedBox(
        width: 300, // Фиксированная ширина
        child: ColorPickerWidget(
          initialColor: _selectedColor,
          onColorChanged: (color) {
            setState(() {
              _selectedColor = color;
            });
          },
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Отмена'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: const Text('Выбрать'),
          onPressed: () => Navigator.of(context).pop(_selectedColor),
        ),
      ],
    );
  }
}