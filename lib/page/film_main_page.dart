import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as request;
import 'package:ilovefilm/channel/film_channel.dart';
import 'package:ilovefilm/page/film_detail_yinfans_page.dart';
import 'package:ilovefilm/page/film_detail_zggqw_page.dart';
import 'package:ilovefilm/util/film_dialog_util.dart';
import 'package:html/parser.dart' show parse;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class  FilmMainPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return FilmMainPageState();
  }

}

class FilmMainPageState extends State<FilmMainPage>  with TickerProviderStateMixin {
  int _selectPosition = 0;
  var _page = 1;
  var _url;

  List<Menu> _menus;

  TabController _controller;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(appBar: AppBar(title: Text('我爱电影'),),
      body: null == _menus ? BaseDialog.getContentLoading() : Column(
        children: <Widget>[
          TabBar(tabs: _menus.map((menu) {
            return Tab(child: Text(
              '${menu.title}', style: TextStyle(color: Color(0xff555555)),),);
          }).toList(), controller: _controller, isScrollable: true,),
          Expanded(child: Container(color: Color(0x55cccccc),
            child: TabBarView(children: _menus.map((menu) {
              return FilmListPage(menu.link,_selectPosition);
            }).toList(), controller: _controller,),),),
        ],),
      drawer: Drawer(child: ListView(children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('images/flutter_drawer_bg.png'),
                  fit: BoxFit.cover)
          ),
        ),
        ListTile(
          title: Text('中国高清网'),
          onTap: () {
            // Update the state of the app
            // ...
            Navigator.pop(context);
            if( 0 == _selectPosition)
              return;
            _saveChannel(FilmChannel.ZGGQW.value);
            _selectPosition = 0;
          },selected: _selectPosition == 0,
        ),
        ListTile(
          title: Text('音范丝'),
          onTap: () {
            // Update the state of the app
            // ...
            Navigator.pop(context);
            if( 1 == _selectPosition)
              return;
            _saveChannel(FilmChannel.YINFANS.value);
            _selectPosition = 1;
          },selected: _selectPosition == 1,
        ),
      ], padding: EdgeInsets.all(0.0),),),);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _requestData();
  }

  void _saveChannel(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('channel', url);
    setState(() {
      _menus = null;
      _controller.dispose();
      _requestData();
    });
  }

  void _requestData() async {
    _url = FilmChannel.ZGGQW.value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String channel = prefs.getString('channel');
    if (null != channel && channel.isNotEmpty) {
      _url = channel;
    }
    if (_url == FilmChannel.YINFANS.value) {
      _selectPosition = 1;
    }
    var response = await request.get(_url);
    var htmlBody = response.body;
    print('respose is  $htmlBody');
    switch(_selectPosition){
      case 1:
        _parseYinFans(htmlBody);
        break;
      case 0:
      default:
      _parseZGGQW(htmlBody);
        break;
    }
  }

  void _parseZGGQW(String body) {
    var document = parse(body);
    //获取菜单
    var menuDocuments = document.getElementById('menus').getElementsByTagName('li');
    _menus = [];
    menuDocuments.forEach((element) {
      String title =element.firstChild.text;
      if(title.isNotEmpty) {
        Menu menu = Menu();
        menu.title = element.text;
        menu.link = element
            .getElementsByTagName('a')
            .first
            .attributes['href'];
        if (!menu.link.startsWith('http:')) {
          menu.link = 'http:' + menu.link;
        }
        _menus.add(menu);
      }
    });
    //默认首选url
    _url = _menus[0].link;
    _controller = TabController(length: _menus.length, vsync: this);
    setState(() {
    });
    print('menus is $_menus');
  }


  void _parseYinFans(String body){
    var document = parse(body);
    //获取菜单
    var menuDocuments = document.getElementsByClassName('mainmenus container').first.getElementsByTagName('li');
    _menus = [];
    menuDocuments.forEach((element) {
      String title = element.text.replaceAll('\n', '').replaceAll('\t', '').replaceAll(' ', '');
      if(title.isNotEmpty) {
        Menu menu = Menu();
        menu.title = element.firstChild.text;
        menu.link = element
            .getElementsByTagName('a')
            .first
            .attributes['href'];
        if (!menu.link.startsWith('http:')) {
          menu.link = 'http:' + menu.link;
        }
        _menus.add(menu);
      }
    });
    //默认首选url
    _url = _menus[0].link;
    _controller = TabController(length: _menus.length, vsync: this);
    setState(() {
    });
    print('menus is $_menus');
  }
}

/// 列表
class FilmListPage extends StatefulWidget{
  final  _url ;
  final _selectPosition;
  FilmListPage(this._url,this._selectPosition);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _FilmListPageState();
  }

}

class _FilmListPageState extends State<FilmListPage> with AutomaticKeepAliveClientMixin<FilmListPage>{
  Widget _content;
  int _page = 1;
  bool _hasMore = true;
  List <FilmBody> _allFilms = [];
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //切记这一行——super.build(context);一定要加，不然Navigator.push/Navigator.pop会导致控件树重绘
    super.build(context);
    return  _content ??BaseDialog.getContentLoading();
  }

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadMore();
  }

  Future<Null>  _loadMore() async {
    if(!_hasMore)
      return;
    var _url = _page >1?'${widget._url}/page/$_page':widget._url;
    try {
      var response = await request.get('$_url');
      var filmDocument = parse(response.body);
      List<FilmBody> films = filmDocument.getElementById('post_container').getElementsByTagName('li').map((element){
            FilmBody filmBody = FilmBody();
            var a = element.getElementsByClassName('thumbnail').first.getElementsByTagName('a').first;
            filmBody.title = a.attributes['title'];
            filmBody.detail = a.attributes['href'];
            filmBody.img = a.getElementsByTagName('img').first.attributes['src'];
            filmBody.date = element.getElementsByClassName('info_date info_ico').first.text;
            StringBuffer buffer = StringBuffer();
            element.getElementsByClassName('info_category info_ico').first.getElementsByTagName('a').forEach((a){
              buffer.write(a.text);
              buffer.write('、');
            });
            filmBody.tag = buffer.toString().substring(0,buffer.length-1);
            return filmBody;
          }).toList();
      if(films.length >= 18){
              _hasMore = true;
            }else{
              _hasMore = false;
            }
      _allFilms.addAll(films);
      int count = 18 > _allFilms.length ? _allFilms.length : _allFilms.length + 1;
      _content = RefreshIndicator(
              child: StaggeredGridView.countBuilder(
                itemCount: count,
                crossAxisCount: 2,
                itemBuilder:(context,position){
                  if(position < count-1 || count < 18) {
                    FilmBody filmBody = _allFilms[position];
                    return InkWell(child:Card(child:Column(children: <Widget>[
                      Image.network(filmBody.img),
                      Container(padding: EdgeInsets.all(8.0),child:Text('${filmBody.title}',style:TextStyle(color: Color(0xff555555)),maxLines: 2,overflow: TextOverflow.ellipsis,) ,)
                    ],),) ,onTap: (){
                      Navigator.push(context, CupertinoPageRoute(builder: (context){
                        return (0 == widget._selectPosition)?FilmDetailZGGQWPage(filmBody.detail,filmBody.title):FilmDetailYinfansPage(filmBody.detail,filmBody.title);
                      }));
                    },);
                  }else{
                    _page++;
                    _loadMore();
                    return BaseDialog.getLoadMoreFoot(_hasMore);
                  }
                },shrinkWrap: true,staggeredTileBuilder:(index) {
                  if(index < count-1 || count < 18) {
                    return StaggeredTile.fit(1);
                  }else{
                   return  StaggeredTile.fit(2);
                  }
              },),onRefresh: (){
                _allFilms.clear();
              _hasMore = true;
              _page = 1;
              return _loadMore();
            },
            );
    } catch (e) {
      _content = Center(child: Text('数据解析失败'),);
    }
      setState(() {
      });
    }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class Menu{
  String title;
  String link ;

  @override
  String toString() {
    // TODO: implement toString
    return 'title = $title & link = $link \n';
  }
}

class FilmBody{
  String title;
  String img;
  String detail;
  String date;
  String tag;

  @override
  String toString() {
    // TODO: implement toString
    return 'title = $title & img = $img  & detail = $detail  & date = $date  & tag = $tag\n';
  }
}