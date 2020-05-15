import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Pattern Lock Screen Flutter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Offset offset;
  List<int> codes = [];

  @override
  Widget build(BuildContext context) {
    var _width = MediaQuery.of(context).size.width;
    var _sizePainter = Size.square(_width);
    return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        backgroundColor: Colors.black,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12)),
              child: GestureDetector(
                child: CustomPaint(
                  painter: _LockScreenPainter(
                      codes: codes, offset: offset, onSelect: _onSelect),
                  size: _sizePainter,
                ),
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
              ),
            ),
            Text(
              codes.join(" "),
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            RaisedButton(child: Text("CLEAR CODE"), onPressed: _clearCodes)
          ],
        ),
      );
  }

  _onPanStart(DragStartDetails event) => _clearCodes();

  _onPanUpdate(DragUpdateDetails event) =>
      setState(() => offset = event.localPosition);

  _onPanEnd(DragEndDetails event) => setState(() => offset = null);

  _onSelect(int code) {
    if (codes.isEmpty || codes.last != code) {
      codes.add(code);
    }
  }

  _clearCodes() => setState(() {
        codes = [];
        offset = null;
      });
}

class _LockScreenPainter extends CustomPainter {
  final int _total = 9;
  final int _col = 3;
  Size size;

  final List<int> codes;
  final Offset offset;
  final Function(int code) onSelect;

  _LockScreenPainter({
    @required this.codes,
    @required this.offset,
    @required this.onSelect,
  });

  double get _sizeCode => size.width / _col;

  Paint get _painter => Paint()
    ..color = Colors.white
    ..strokeWidth = 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    this.size = size;

    for (var i = 0; i < _total; i++) {
      var _offset = _getOffetByIndex(i);
      var _color = _getColorByIndex(i);

      var _radiusIn = _sizeCode / 2.0 * 0.2;
      _drawCircle(canvas, _offset, _radiusIn, _color, true);

      var _radiusOut = _sizeCode / 2.0 * 0.6;
      _drawCircle(canvas, _offset, _radiusOut, _color);

      var _pathGesture = _getCirclePath(_offset, _radiusOut);
      if (offset != null && _pathGesture.contains(offset)) onSelect(i);
    }

    for (var i = 0; i < codes.length; i++) {
      var _start = _getOffetByIndex(codes[i]);
      if (i + 1 < codes.length) {
        var _end = _getOffetByIndex(codes[i + 1]);
        _drawLine(canvas, _start, _end);
      } else if (offset != null) {
        var _end = offset;
        _drawLine(canvas, _start, _end);
      }
    }
  }

  Path _getCirclePath(Offset offset, double radius) {
    var _rect = Rect.fromCircle(radius: radius, center: offset);
    return Path()..addOval(_rect);
  }

  void _drawCircle(Canvas canvas, Offset offset, double radius, Color color,
      [bool isDot = false]) {
    var _path = _getCirclePath(offset, radius);
    var _painter = this._painter
      ..color = color
      ..style = isDot ? PaintingStyle.fill : PaintingStyle.stroke;
    canvas.drawPath(_path, _painter);
  }

  void _drawLine(Canvas canvas, Offset start, Offset end) {
    var _painter = this._painter
      ..color = Colors.lightGreenAccent.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    var _path = Path();
    _path.moveTo(start.dx, start.dy);
    _path.lineTo(end.dx, end.dy);
    canvas.drawPath(_path, _painter);
  }

  Color _getColorByIndex(int i) {
    return codes.contains(i) ? Colors.lightGreenAccent.shade700 : Colors.white;
  }

  Offset _getOffetByIndex(int i) {
    var _dxCode = _sizeCode * (i % _col + .5);
    var _dyCode = _sizeCode * ((i / _col).floor() + .5);
    var _offsetCode = Offset(_dxCode, _dyCode);
    return _offsetCode;
  }

  @override
  bool shouldRepaint(_LockScreenPainter oldDelegate) {
    return offset != oldDelegate.offset;
  }
}
