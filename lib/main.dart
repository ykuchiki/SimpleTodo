import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "dart:convert";

void main(){
  // 最初に表示するWidget
  runApp(SimpleTodoApp());
}

class SimpleTodoApp extends StatefulWidget{
@override
  _SimpleTodoAppState createState() => _SimpleTodoAppState();
}

class _SimpleTodoAppState extends State<SimpleTodoApp> {
  ThemeData _themeData = ThemeData(
    primarySwatch: Colors.blue,  // デフォルト値を設定
    primaryColor: Colors.blue,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.blue,
    ),
  );

  @override
  void initState() {
    super.initState();
    loadThemeColor().then((color) {
      setState(() {
        _themeData = ThemeData(
          primarySwatch: createMaterialColor(color),
          primaryColor: color,
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: createMaterialColor(color),
          ),
        );
      });
    });
  }

  void _changeTheme(Color color) {
    setState(() {
      _themeData = ThemeData(
        primarySwatch: createMaterialColor(color),
        primaryColor: color,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: createMaterialColor(color),
        ),
      );
      saveThemeColor(color); // テーマの色を保存
    });
  }

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      // アプリ名
      title: "Simple Todo App",
      theme: _themeData,
      // リスト一覧画面を表示，これがないと何も表示されない
      home: TodoListPage(onThemeChanged: _changeTheme),
    );
  }
}

class TodoListPage extends StatefulWidget{
  final Function(Color) onThemeChanged;

  TodoListPage({required this.onThemeChanged});
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

// リスト一覧画面用Widget
class _TodoListPageState extends State<TodoListPage>{
  // Todoリストのデータ
  List<TodoItem> todoList = [];

  @override
  void initState() {
    super.initState();
    loadTodoList().then((loadedList) {
      setState(() {
        todoList = loadedList;
      });
    });
  }


  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo list", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        leading: PopupMenuButton<String>(
          onSelected: (String value){
            // テーマ変更のロジック
            if (value == "Theme1") {
              widget.onThemeChanged(Colors.blue);
            } else if (value == "Theme2") {
              widget.onThemeChanged(createMaterialColor(Color.fromARGB(255, 2, 156, 28)));
            } else if (value == "Theme3") {
              widget.onThemeChanged(Colors.red);
            } else if (value == "Theme4") {
              widget.onThemeChanged(Colors.black);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: "Theme1",
              child: Text("Blue Theme"),
            ),
            const PopupMenuItem<String>(
              value: "Theme2",
              child: Text("Green Theme"),
            ),
            const PopupMenuItem<String>(
              value: "Theme3",
              child: Text("Red Theme"),
            ),
            const PopupMenuItem<String>(
              value: "Theme4",
              child: Text("black Theme"),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView.builder(
        itemCount: todoList.length,
        itemBuilder: (context, index){
          final item = todoList[index];
          return Card(
            child: ListTile(
              title: Text(
                item.text,
                style: TextStyle(
                  decoration: item.isChecked ? TextDecoration.lineThrough : null,
                ),
              ),
              leading: Checkbox(
                value: item.isChecked,
                onChanged: (bool? newValue){
                  setState(() {
                    item.isChecked = newValue ?? false;
                    saveTodoList(todoList);
                  });
                },
              ),
              trailing: IconButton(
                icon: Icon(Icons.close),
                onPressed: (){
                  setState(() {
                    todoList.removeAt(index);
                    saveTodoList(todoList);  // TodoListの保存
                  });
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          // pushで画面遷移
          final newListText = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context){
              // 遷移先の画面としてリスト追加画面を指定
              return TodoAddPage();
            }),
          );
          if (newListText != null){
            //キャンセルの場合はnull
            setState((){
              // リスト追加
              todoList.add(newListText as TodoItem);
              saveTodoList(todoList);
            });
          }
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
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((r - 255).abs() * ds).round(),
      g + ((g - 255).abs() * ds).round(),
      b + ((b - 255).abs() * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

class TodoAddPage extends StatefulWidget{
  @override
  _TodoAddPageState createState() => _TodoAddPageState();
}

// リスト追加用Widget
class _TodoAddPageState extends State<TodoAddPage>{
  // 入力されたテキストをデータとしてもつ
  String _text = "";

  // データを元に表示するWidget
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("add a list" ,style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        // 余白
        padding: EdgeInsets.all(64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 入力されたテキストを表示
            //Text(_text, style: TextStyle(color: createMaterialColor(Color.fromARGB(255, 2, 156, 28)))),
            const SizedBox(height: 8),
            //テキスト入力
            TextField(
              // 入力されたテキストの値を受け取る (valueが入力されたテキスト)
              onChanged: (String value){
                // データが変更したことを知らせる (画面更新)
                setState((){
                  // データ変更
                  _text = value;
                });
              },
              keyboardType: TextInputType.multiline, // キーボードタイプを multiline に設定
              maxLines: null, // maxLines を null に設定して複数行を許可
            ),
            const SizedBox(height: 8),
            Container(
              // 横幅いっぱいに広げる
              width: double.infinity,
              // リスト追加ボタン
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  // popで前の画面に戻る
                  // popの引数から前の画面にデータを渡す
                  Navigator.of(context).pop(TodoItem(text: _text));
                },
                child: Text("add a list", style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              // 横幅いっぱいに広げる
              width: double.infinity,
              // キャンセルボタン
              child: TextButton(
                // クリックした時
                onPressed:  (){
                  // popで前の画面に戻る
                  // popの引数から前の画面にデータを渡す
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TodoItem {
  String text;
  bool isChecked;

  TodoItem({required this.text, this.isChecked = false});

  // JSONからTodoItemを生成するファクトリコンストラクタ
  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      text: json['text'],
      isChecked: json['isChecked'],
    );
  }

  // TodoItemをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isChecked': isChecked,
    };
  }
}

// Todoリストを保存する関数
Future<void> saveTodoList(List<TodoItem> todoList) async{
  final prefs = await SharedPreferences.getInstance();
  // TodoリストをJSON形式に変換して保存
  prefs.setString("todoList", jsonEncode(todoList.map((item) =>item.toJson()).toList()));
}

// Todoリストを読み込む関数
Future<List<TodoItem>> loadTodoList() async {
  final prefs = await SharedPreferences.getInstance();
  // 保存されたTodoリストを読み込み
  final String? todoListString = prefs.getString('todoList');
  if (todoListString != null) {
    // JSON形式からTodoリストに変換
    return (jsonDecode(todoListString) as List).map((item) => TodoItem.fromJson(item)).toList();
  }
  return [];
}

// テーマの色を保存する関数
Future<void> saveThemeColor(Color color) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setInt('themeColor', color.value);
}

// 保存されたテーマの色を読み込む関数
Future<Color> loadThemeColor() async {
  final prefs = await SharedPreferences.getInstance();
  int colorValue = prefs.getInt('themeColor') ?? Colors.blue.value; // デフォルトは青色
  return Color(colorValue);
}
