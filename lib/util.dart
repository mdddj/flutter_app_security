import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class Utils {
  static const String IP = "http://192.168.199.118:8089";
  static const String _KEY = "76CAA1C88F7F8D1D";
  static const String _IV = "91129048100F0494";

  /// 根据request参数的key进行排序,并生成一个新的map返回
  static Map<String, String> keySort(Map<String, String> oldParamsMap) {
    Map<String, String> newParamsMap = Map();
    String timeToken = DateTime.now().millisecondsSinceEpoch.toString();
    oldParamsMap["timeToken"] = timeToken; // 给参数加上时间戳
    List<String> oldKeys = oldParamsMap.keys.toList();
    if (oldKeys.isEmpty) return newParamsMap;
    oldKeys.sort((a, b) {
      List<int> al = a.codeUnits;
      List<int> bl = b.codeUnits;
      for (int i = 0; i < al.length; i++) {
        if (bl.length <= i) return 1;
        if (al[i] > bl[i]) {
          return 1;
        } else if (al[i] < bl[i]) return -1;
      }
      return 0;
    });
    // print(oldKeys);
    for (int i = 0; i < oldKeys.length; i++) {
      newParamsMap[oldKeys[i]] = oldParamsMap[oldKeys[i]];
    }

    return newParamsMap;
  }

  /// 生成token
  static String generateToken(Map<String, String> params) {
    String value = json.encode(params);
    // utf8编码
    // print("编码前的串串:$value");
    value = base64Encode(utf8.encode(value));
    // print("编码后的串串:$value");
    value = encryptMD5(value);
    return value;
  }

  /// aes 加密
  static String encryptAESCbc128WithPadding7(String val) {
    String v = "";
    try {
      final encrypter = Encrypter(AES(Key.fromUtf8(_KEY), mode: AESMode.cbc));
      final encrypted = encrypter.encrypt(val, iv: IV.fromUtf8(_IV));
      return encrypted.base64;
    } catch (err) {
      print("加密失败:$err");
    }
    return v;
  }

  /// md5 加密
  static String encryptMD5(String data) {
    var content = new Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    return digest.toString();
  }

}
