import 'dart:convert';

import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:encrypt_app/result.dart';
import './util.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _deviceId = ""; // 设备id
  Map<String,dynamic> _response; // 服务器返回的数据
  String _decodeStr = "";// 机密后的数据

  @override
  void initState() {
    super.initState();
    _getDeviceId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("加密请求测试"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text("设备id是:$_deviceId"),
            MaterialButton(child: Text("获取设备id"), onPressed: _getDeviceId),
            MaterialButton(
              onPressed: _getAccessToken,
              child: Text("获取服务器token"),
            ),
            MaterialButton(
              onPressed: _paramsSort,
              child: Text("参数排序"),
            ),
            MaterialButton(
              onPressed: _getCategory,
              child: Text("请求商品数据"),
            ),
            MaterialButton(
              onPressed: _decode,
              child: Text("解密数据"),
            ),
            Column(
              children: [Divider(), Text(_decodeStr.isNotEmpty ? _decodeStr : _response.toString())],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _decode()async{
   Result result = Result.fromJson(_response);
   var value = Utils.aesDecrypt(result.data);
   setState(() {
     _decodeStr = value;
   });
   print("解密后的数据:$value");
  }

  Future<void> _getCategory() async {
    var data = {"id": "30743541"};
    Map<String, String> newParams = Utils.keySort(data);
    String token = Utils.generateToken(newParams); // 获取token
    String aesStr = Utils.encryptAESCbc128WithPadding7(base64Encode(utf8.encode(json.encode(newParams))));

    Dio dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (RequestOptions options){
        options.headers["params_token"] = token;
      }
    ));
    Response response = await dio.get("${Utils.IP}/tkapi/api/v1/dtk/apis/detail", queryParameters: {"data": aesStr});
    setState(() {
      _response = response.data;
    });
  }

  Future<void> _paramsSort() async {
    Map<String, String> params = Map();
    // params["pageId"] = "1";
    // params["pageSize"] = "10";
    // params["sort"] = "1";
    // params["goodsId"] = "053453";
    // params["ablout"] = "测试";
    // params["zoom"] = "145";
    // params["boot"] = "spring";
    params["id"] = "30743541";
    Map<String, String> newParams = Utils.keySort(params);
    String token = Utils.generateToken(newParams); // 获取token
    print("需要放到header的token值:$token");
    //获取加密后的参数
    String aesStr = Utils.encryptAESCbc128WithPadding7(base64Encode(utf8.encode(json.encode(newParams))));
    print("传输给服务器的aes数据:$aesStr");
  }

  Future<void> _getAccessToken() async {
    Response response;
    Dio dio = Dio();
    response = await dio.post("${Utils.IP}/openapi/getToken", data: {"deviceId": _deviceId});
    setState(() {
      _response = response.data;
    });
  }

  Future<void> _getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    setState(() {
      _deviceId = androidInfo.androidId;
    });
  }
}
