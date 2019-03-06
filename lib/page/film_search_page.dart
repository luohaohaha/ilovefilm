import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ilovefilm/page/film_main_page.dart';

class FilmSearchPage extends  StatefulWidget{
  final _url;
  final _selectPosition;

  FilmSearchPage(this._url,this._selectPosition);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return FilmSearchPageState();
  }
}

class FilmSearchPageState extends State<FilmSearchPage>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(appBar: AppBar(title: Text('搜索'),),body:FilmListPage(widget._url,widget._selectPosition),);
  }
}