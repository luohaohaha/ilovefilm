import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as request;
import 'package:ilovefilm/util/film_dialog_util.dart';
import 'package:html/parser.dart' show parse;
import 'package:url_launcher/url_launcher.dart';

class FilmDetailZGGQWPage extends StatefulWidget{
  final _detailUrl;
  final _name;

  FilmDetailZGGQWPage(this._detailUrl,this._name);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return FilmDetailZGGQWPageState();
  }

}

class FilmDetailZGGQWPageState  extends State<FilmDetailZGGQWPage>{
  var _content;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(body:_content??BaseDialog.getContentLoading() ,);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _requestDetail();
  }

  void _requestDetail() async{
    //请求
    var response = await request.get(widget._detailUrl);
    var _imageUrl;
    //获取内容节点
    var document = parse(response.body).getElementById('post_content');
    //解析p
    List<String> ps = [];
    document.getElementsByTagName('p').forEach((p){
      //获取封面
      var img = p.getElementsByTagName('img');
      if(null != img && img.isNotEmpty && null == _imageUrl){
        _imageUrl = img.first.attributes['src'];
      }
      if(null == img || img.isEmpty){
        String text=p.text;
        String magnet;
        //获取磁力链接
        try {
          magnet = p.getElementsByTagName('span').first.getElementsByTagName('a').first.attributes['href'];
        } catch (e) {
          magnet = null;
        }
        //拼接，暂时用&&标记
        if(null !=magnet){
          text+='&&$magnet';
        }
        ps.add(text);
      }
    });
    setState(() {
      _content = ps.isEmpty?Center(child: Text('没有数据'),):NestedScrollView(headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled){
        return <Widget>[
          SliverAppBar(
            expandedHeight: 300.0 ,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
                title: ConstrainedBox(constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width-120),child:Text('${widget._name}',maxLines: 1,textAlign:TextAlign.center,overflow: TextOverflow.ellipsis,
        style: TextStyle(
        color: Colors.white,
        fontSize: 16.0,
        )) ,),
                background: Image.network(
                 _imageUrl,
                  fit: BoxFit.fitWidth,alignment: Alignment.topLeft,
                )),
          ),
        ];
      }, body: SingleChildScrollView(child: Container(child: Column(
        children: ps.map((pText){
          //处理磁力链接点击事件跳转
          if(pText.contains('&&')){
           List<String>texts = pText.split('&&');
            return InkWell(child: Container(child: Text(texts[0],style: TextStyle(color: Colors.white,height: 1.5)),padding: EdgeInsets.all(8.0),margin:EdgeInsets.only(bottom: 8.0),decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5.0)),color:Theme.of(context).primaryColor ),),onTap: (){
              print('magnet ======== ${texts[1]}');
              _launcherUrl(texts[1]);
            },);
          }
          //无磁力链接只显示内容
          return Text(pText,style: TextStyle(color: Color(0xff333333),height: 1.5));
        }).toList(),mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
      ),margin: EdgeInsets.all(8.0),),));
    });
  }

  void _launcherUrl(String url) async{
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
