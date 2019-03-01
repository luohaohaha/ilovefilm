import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as request;
import 'package:ilovefilm/util/film_dialog_util.dart';
import 'package:html/parser.dart' show parse;

class FilmDetailPage extends StatefulWidget{
  final _detailUrl;
  final _name;

  FilmDetailPage(this._detailUrl,this._name);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return FilmDetailPageState();
  }

}

class FilmDetailPageState  extends State<FilmDetailPage>{
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
    var response = await request.get(widget._detailUrl);
    var _imageUrl;
    var document = parse(response.body).getElementById('post_content');
    List<String> ps = [];
    document.getElementsByTagName('p').forEach((p){
      var img = p.getElementsByTagName('img');
      if(null != img && img.isNotEmpty && null == _imageUrl){
        _imageUrl = img.first.attributes['src'];
      }
      if(null == img || img.isEmpty){
        ps.add(p.text);
      }
    });
    //SingleChildScrollView(child: Column(children: <Widget>[
    //        Image.network(_imageUrl),
    //       Column(
    //          children: ps.map((pText){
    //            return Text(pText,style: TextStyle(color: Color(0xff333333)),);
    //          }).toList(),mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
    //        ),
    //      ],),)
    setState(() {
      _content = ps.isEmpty?Center(child: Text('没有数据'),):NestedScrollView(headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled){
        return <Widget>[
          SliverAppBar(
            expandedHeight: 300.0 ,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
                title: Container(child: Text('${widget._name}',maxLines: 1,overflow: TextOverflow.ellipsis,
        style: TextStyle(
        color: Colors.white,
        fontSize: 16.0,
        )),color: Color(0x55000000),),
                background: Image.network(
                 _imageUrl,
                  fit: BoxFit.fitWidth,alignment: Alignment.topLeft,
                )),
          ),
        ];
      }, body: SingleChildScrollView(child: Column(
        children: ps.map((pText){
          return Text(pText,style: TextStyle(color: Color(0xff333333)),);
        }).toList(),mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
      ),));
    });
  }
}
