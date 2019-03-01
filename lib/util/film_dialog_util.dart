import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class BaseDialog {
  static Future showLoading(BuildContext context, String text, bool cancel) async {
    await  showDialog(
          context: context,
          builder: (context) {
            return  WillPopScope(
                child: Platform.isAndroid? AlertDialog(
                    content:  Column(
                      children: <Widget>[
                        const CircularProgressIndicator(),
                        const SizedBox(height: 10.0, width: 0.0),
                         Text(text ?? "请稍后...")
                      ],
                      mainAxisSize: MainAxisSize.min,
                    )):CupertinoAlertDialog(
                    content:  Column(
                      children: <Widget>[
                        const CircularProgressIndicator(),
                        const SizedBox(height: 10.0, width: 0.0),
                        Text(text ?? "请稍后...")
                      ],
                      mainAxisSize: MainAxisSize.min,
                    )),
                onWillPop: () async => cancel);
          });

  }



  static void showError(BuildContext context, String title,String error, bool cancel) {
    showDialog(
        context: context,
        builder: (context) {
          final ThemeData theme = Theme.of(context);
          return  WillPopScope(
              child: Platform.isAndroid? AlertDialog(
                title:  Text((null == title || title.isEmpty)?'提示':title),
                content:  Column(
                  children: <Widget>[ Text(error ?? '',style: TextStyle(color: theme.textTheme.caption.color,fontSize: 15.0),)],
                  mainAxisSize: MainAxisSize.min,
                ),
                actions: <Widget>[
                   FlatButton(
                      child: const Text('确定'),
                      onPressed: () {
                        Navigator.pop(context);
                      })
                ],titlePadding: EdgeInsets.all(16.0),contentPadding: EdgeInsets.all(16.0),
              ):CupertinoAlertDialog(
                title:  Text((null == title || title.isEmpty)?'提示':title),
                content:  Column(
                  children: <Widget>[ Text(error ?? '',style: TextStyle(color: theme.textTheme.caption.color,fontSize: 15.0),)],
                  mainAxisSize: MainAxisSize.min,
                ),
                actions: <Widget>[
                  FlatButton(
                      child: const Text('确定'),
                      onPressed: () {
                        Navigator.pop(context);
                      })
                ],
              ),
              onWillPop: () async => cancel);
        },barrierDismissible: cancel);
  }
  
  static void showTip(BuildContext context, String title,String tip, List<Widget> actions,bool cancel) {
    showDialog(
        context: context,
        builder: (context) {
          final ThemeData theme = Theme.of(context);
          return  WillPopScope(
              child:  Platform.isAndroid?AlertDialog(
                title:  Text((null == title || title.isEmpty)?'提示':title),
                content: Text(tip ?? '',style: TextStyle(color: theme.textTheme.caption.color,fontSize: 15.0)),
                actions:actions,titlePadding: EdgeInsets.all(16.0),contentPadding: EdgeInsets.all(16.0),
              ):CupertinoAlertDialog(
                title:  Text((null == title || title.isEmpty)?'提示':title),
                content: Text(tip ?? '',style: TextStyle(color: theme.textTheme.caption.color,fontSize: 15.0)),
                actions:actions,
              ),
              onWillPop: () async => cancel);
        },barrierDismissible: cancel);
  }

 static  Widget getContentLoading({String  msg}){
    return Center(child: Column(
      children: <Widget>[
        const CircularProgressIndicator(),
        const SizedBox(height: 10.0, width: 0.0),
         Text(msg??'正在加载数据，请稍后...')
      ],
      mainAxisSize: MainAxisSize.min,
    ),);
  }

  static Widget getLoadMoreFoot(bool _hasMore){
    return Row(
      children: <Widget>[
        _hasMore ?  Container(child: CircularProgressIndicator(strokeWidth: 2.0,), width: 15.0, height: 15.0,) :
        Container(),
        SizedBox(height: 10.0, width: 5.0),
        Container(child: Text(_hasMore ? "正在加载，请稍后..." : '-------没有更多数据啦-------'), padding: EdgeInsets.all(10.0),)
      ],
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
    );
  }

  static Widget getAppBar(String title,{List<Widget> actions}){
    return PreferredSize(child:AppBar(title: Text(title),centerTitle: true,actions: actions,elevation: .0,) , preferredSize: Size.fromHeight(45.0));
  }
}
