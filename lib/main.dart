import "package:flutter/material.dart";

void main(){
  // 最初に表示するWidget
  runApp(SimpleTodo());
}

class SimpleTodo extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      // アプリ名
      title: "Simple Todo",
      theme: ThemeData(
        primarySwatch: createMaterialColor(Color.fromARGB(255, 2, 156, 28)),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: createMaterialColor(Color.fromARGB(255, 2, 156, 28)),
        )
      ),
      // リスト一覧画面を表示，これがないと何も表示されない
      home: TodoListPage(),
    );
  }
}

// リスト一覧画面用Widget
class TodoListPage extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo list",style: TextStyle(color: Colors.white),),
        backgroundColor: createMaterialColor(Color.fromARGB(255, 2, 156, 28)),
      ),
      body: Center(
        child:  Text("リスト一覧画面"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          // pushで画面遷移
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context){
              // 遷移先の画面としてリスト追加画面を指定
              return TodoAddPage();
            }),
          );
        },
        child:Icon(Icons.add,color: Colors.white,)
      ),
    );
  }
}

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((r - 255).abs() * ds).round(),
      g + ((g - 255).abs() * ds).round(),
      b + ((b - 255).abs() * ds).round(),
      1,
    );
  });
  return MaterialColor(color.value, swatch);
}

// リスト追加用Widget
class TodoAddPage extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: (){
            // popで前の画面に戻る
            Navigator.of(context).pop();
          },
          child: Text("リスト追加画面(クリックで戻る)"),
        ),
      ),
    );
  }
}