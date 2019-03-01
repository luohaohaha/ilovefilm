import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as request;
import 'package:ilovefilm/util/film_dialog_util.dart';
import 'package:html/parser.dart' show parse;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class  FilmMainPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return FilmMainPageState();
  }

}

class FilmMainPageState extends State<FilmMainPage>  with TickerProviderStateMixin {
  var _page = 1;
  var _url = 'http://gaoqing.la/';
  List<Menu> _menus ;
  TabController _controller ;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(appBar:AppBar(title: Text('我爱电影'),),body: null == _menus?BaseDialog.getContentLoading():Column(children: <Widget>[
      TabBar(tabs: _menus.map((menu){
        return Tab(child: Text('${menu.title}',style: TextStyle(color: Color(0xff555555)),),);
      }).toList(),controller: _controller,isScrollable: true,),
      Expanded(child: Container(color: Color(0x55cccccc),child:TabBarView(children: _menus.map((menu){
    return FilmListPage(menu.link);
    }).toList(),controller: _controller,) ,),),
    ],),);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _requestData();
  }


  void _requestData() async{
    var response = await request.get(_url);
    var htmlBody = response.body;
    print('respose is  $htmlBody');
    var document = parse(htmlBody);
    //获取菜单
    var menuDocuments = document.getElementById('menus').getElementsByTagName('li');
    _menus = menuDocuments.map((element){
      Menu menu = Menu();
      menu.title = element.text;
      menu.link = element.getElementsByTagName('a').first.attributes['href'];
      if(!menu.link.startsWith('http:')){
        menu.link = 'http:'+menu.link;
      }
      return menu;
    }).toList();
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
  FilmListPage(this._url);

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
                Container(padding: EdgeInsets.all(8.0),child:Text('${filmBody.title}',style:TextStyle(color: Color(0xff555555)),maxLines: 1,overflow: TextOverflow.ellipsis,) ,)
              ],),) ,onTap: (){

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