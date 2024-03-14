
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Toolbox App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ToolboxPage(),
    );
  }
}

class ToolboxPage extends StatefulWidget {
  @override
  _ToolboxPageState createState() => _ToolboxPageState();
}

class _ToolboxPageState extends State<ToolboxPage> {
  String _name = '';
  String _gender = '';
  String _ageGroup = '';
  String _country = 'Dominican Republic';
   Map<String, dynamic> _weather = {};
  List<dynamic> _universities = [];
  List<dynamic> _news = [];

  TextEditingController _nameController = TextEditingController();

  Future<void> _fetchGenderAndColor(String name) async {
    final response = await http.get(Uri.parse('https://api.genderize.io/?name=$name'));
    final data = json.decode(response.body);
    setState(() {
      _gender = data['gender'];
    });
  }

  Future<void> _fetchAgeGroup(String name) async {
    final response = await http.get(Uri.parse('https://api.agify.io/?name=$name'));
    final data = json.decode(response.body);
    final age = data['age'] as int;
    setState(() {
      if (age <= 25) {
        _ageGroup = 'joven';
      } else if (age <= 60) {
        _ageGroup = 'adulto';
      } else {
        _ageGroup = 'anciano';
      }
    });
  }

  Future<void> _fetchUniversities(String country) async {
    final response = await http.get(Uri.parse(
        'http://universities.hipolabs.com/search?country=${country.replaceAll(' ', '+')}'));
    final data = json.decode(response.body);
    setState(() {
      _universities = data;
    });
  }

  Future<void> _fetchWeather() async {
  final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=Fantino,do&APPID=279b09c1c21a93cd0edeedd4f4054239')); 
    if (response.statusCode == 200) {
      setState(() {
        _weather = json.decode(response.body); 
      });
    } else {
      throw Exception('Failed to load weather data');
    }
   
  }

  Future<void> _fetchWordpressNews() async {

    setState(() {
      _news = [
        {
          'title': 'Título de la noticia 1',
          'summary': 'Resumen de la noticia 1',
          'link': 'https://example.com/news/1',
        },
        {
          'title': 'Título de la noticia 2',
          'summary': 'Resumen de la noticia 2',
          'link': 'https://example.com/news/2',
        },
        {
          'title': 'Título de la noticia 3',
          'summary': 'Resumen de la noticia 3',
          'link': 'https://example.com/news/3',
        },
      ];
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchUniversities(_country);
    _fetchWeather();
    _fetchWordpressNews();
  }
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Acerca de'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
             Image.asset(
              'assets/yo.jpeg',
              height: 200,
              fit: BoxFit.cover,
            ),
              SizedBox(height: 10),
              Text('Datos de Contacto:'),
              Text('Jhonjansel Hilario'),
              Text('Correo Electrónico: Jhonjansel18@gmail.com'),
              Text('Teléfono: +1(829)-942-8599'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Toolbox App'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.info),
            onPressed: _showAboutDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Image.asset(
              'assets/toolbox.jpeg',
              height: 200,
              fit: BoxFit.fill,
           
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nombre'),
              onChanged: (value) {
                setState(() {
                  _name = value;
                });
              },
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _fetchGenderAndColor(_name);
                _fetchAgeGroup(_name);
              },
              child: Text('Predecir Género y Color'),
            ),
            SizedBox(height: 20),
            _gender.isNotEmpty
                ? Container(
                    width: 100,
                    height: 100,
                    color: _gender == 'male' ? Colors.blue : Colors.pink,
                  )
                : Container(),
            SizedBox(height: 20),
            _ageGroup.isNotEmpty
                ? Column(
                    children: [
                      Text(
                        'Grupo de Edad: $_ageGroup',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Image.asset(
                        _ageGroup == 'joven'
                            ? 'assets/young.png'
                            : _ageGroup == 'adulto'
                                ? 'assets/adult.png'
                                : 'assets/elderly.png',
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ],
                  )
                : Container(),
            SizedBox(height: 20),
            Text(
              'Universidades en $_country:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _universities.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _universities
                        .map<Widget>((uni) => ListTile(
                              title: Text(uni['name']),
                              subtitle: Text('Dominio: ${uni['domains'].first}'),
                              onTap: () => print('Abrir página web: ${uni['web_pages'].first}'),
                            ))
                        .toList(),
                  )
                : CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
                  'Weather in Fantino, Dominican Republic:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text('Temperature: ${_weather['main']['temp']}°C'),
                Text('Description: ${_weather['weather'][0]['description']}'),
                Text('Humidity: ${_weather['main']['humidity']}%'),
                Text('Wind Speed: ${_weather['wind']['speed']} m/s'),
            SizedBox(height: 20),
            Text(
              'Últimas noticias de WordPress:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _news.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _news
                        .map<Widget>((article) => Card(
                              child: ListTile(
                                title: Text(article['title']),
                                subtitle: Text(article['summary']),
                                onTap: () => print('Abrir noticia: ${article['link']}'),
                              ),
                            ))
                        .toList(),
                  )
                : CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
