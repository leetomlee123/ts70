import 'dart:async';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:fast_gbk/fast_gbk.dart';

class Request {
  static final Request _instance = Request._internal();

  factory Request() => _instance;

  late Dio dio;

  Request._internal() {
    BaseOptions options = BaseOptions(
      baseUrl: "",
      connectTimeout: 20000,
      receiveTimeout: 5000,
      headers: {
        "User-Agent":
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.110 Safari/537.36 Edg/96.0.1054.62",
      },
      contentType: 'application/json; charset=utf-8',
      responseType: ResponseType.json,
    );

    dio = Dio(options);
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback = (cert, host, port) {
        return true; // 返回true强制通过
      };
    };
    // dio.interceptors.add(RetryInterceptor(
    //   dio: dio,
    //   logPrint: print, // specify log function (optional)
    //   retries: 3, // retry count (optional)
    //   retryDelays: const [
    //     Duration(seconds: 1), // wait 1 sec before first retry
    //     Duration(seconds: 2), // wait 2 sec before second retry
    //     Duration(seconds: 3), // wait 3 sec before third retry
    //   ],
    // ));
    // 添加拦截器
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      // 在请求被发送之前做一些预处理
      return handler.next(options); //continue
    }, onResponse: (response, handler) {
      // 在返回响应数据之前做一些预处理
      return handler.next(response);
    }, onError: (DioError e, handler) {
      // 当请求失败时做一些预处理
      // ErrorEntity eInfo = createErrorEntity(e);
      // 错误提示
      // BotToast.showText(text:eInfo.message.toString());
      // 错误交互处理
      // switch (eInfo.code) {
      //   case 401: // 没有权限 重新登录
      //     // deleteTokenAndReLogin();
      //     break;
      //   default:
      // }
      // return handler.reject(e);
      throw Exception(e);
    }));
  }

  /// 读取token
  Map<String, dynamic> getAuthorizationHeader() {
    var headers = {"": ""};
    return headers;
  }

  /// restful get 操作
  Future getBase(
    String path,
  ) async {
    var response = await dio.get(path);
    return response;
  }

  /// restful get 操作
  Future get(String path,
      {dynamic params, Options? options, String? proxy = ""}) async {
    // if (proxy!.isNotEmpty) {
    //   (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
    //       (client) {
    //     // config the http client
    //     client.findProxy = (uri) {
    //       //proxy all request to localhost:8888
    //       return 'PROXY $proxy';
    //     };
    //     // you can also create a HttpClient to dio
    //     // return HttpClient();
    //   };
    // }
    var response = await dio.get(
      path,
      queryParameters: params,
      // options: Options(responseDecoder: gbkDecoder),
    );
    return response.data;
  }

  Future getCommon(String path,
      {dynamic params, Options? options, String? proxy = ""}) async {
    Options requestOptions = options ?? Options();
    var response = await dio.get(
      path,
      queryParameters: params,
      options: requestOptions,
    );
    return response.data;
  }

  /// restful post 操作
  Future post(
    String path, {
    dynamic params,
    Options? options,
    bool? useToken = true,
  }) async {
    Options requestOptions = options ?? Options();

    Map<String, dynamic> _authorization = getAuthorizationHeader();
    if (useToken! && _authorization.isNotEmpty) {
      requestOptions = requestOptions.copyWith(headers: _authorization);
    }

    var response = await dio.post(
      path,
      data: params,
      options: requestOptions,
    );
    return response.data;
  }

  /// restful put 操作
  Future put(String path, {dynamic params, Options? options}) async {
    Options requestOptions = options ?? Options();
    Map<String, dynamic> _authorization = getAuthorizationHeader();
    if (_authorization.isNotEmpty) {
      requestOptions = requestOptions.copyWith(headers: _authorization);
    }
    var response = await dio.put(
      path,
      data: params,
      options: requestOptions,
    );
    return response.data;
  }

  /// restful patch 操作
  Future patch(String path, {dynamic params, Options? options}) async {
    Options requestOptions = options ?? Options();

    Map<String, dynamic> _authorization = getAuthorizationHeader();
    if (_authorization.isNotEmpty) {
      requestOptions = requestOptions.copyWith(headers: _authorization);
    }

    var response = await dio.patch(
      path,
      data: params,
      options: requestOptions,
    );

    return response.data;
  }

  Future patchForm(String path, {dynamic params, Options? options}) async {
    Options requestOptions = options ?? Options();

    Map<String, dynamic> _authorization = getAuthorizationHeader();
    if (_authorization.isNotEmpty) {
      requestOptions = requestOptions.copyWith(headers: _authorization);
    }

    var response = await dio.patch(
      path,
      data: FormData.fromMap(params),
      options: requestOptions,
    );

    return response.data;
  }

  /// restful delete 操作
  Future delete(String path, {dynamic params, Options? options}) async {
    Options requestOptions = options ?? Options();

    Map<String, dynamic> _authorization = getAuthorizationHeader();
    if (_authorization.isNotEmpty) {
      requestOptions = requestOptions.copyWith(headers: _authorization);
    }
    var response = await dio.delete(
      path,
      data: params,
      options: requestOptions,
    );
    return response.data;
  }

  /// restful post form 表单提交操作
  Future postForm(String path,
      {dynamic params,
      Options? options,
      bool? useToken = true,
      CancelToken? cancelToken}) async {
    Options requestOptions = options ?? Options();

    Map<String, dynamic> _authorization = getAuthorizationHeader();

    if (useToken! && _authorization.isNotEmpty) {
      requestOptions = requestOptions.copyWith(headers: _authorization);
    }
    var response = await dio.post(path,
        data: FormData.fromMap(params),
        options: requestOptions,
        cancelToken: cancelToken);
    return response.data;
  }

  String gbkDecoder(List<int> responseBytes, RequestOptions options,
      ResponseBody responseBody) {
    return gbk.decode(responseBytes);
  }

  List<int> gbkEncoder(
    String req,
    RequestOptions options,
  ) {
    return gbk.encode(req);
  }

  Future postForm1(String path,
      {String? params, Options? options, bool? useToken = true}) async {
    dio.options.contentType = 'application/x-www-form-urlencoded';
    var response = await dio.post(
      path,
      data: params,
      options: Options(responseDecoder: gbkDecoder),
    );
    return response.data;
  }

  Future postForm2(String path,
      {String? params, Options? options, bool? useToken = true}) async {
    dio.options.contentType = 'application/x-www-form-urlencoded';
    var response = await dio.post(
      path,
      data: params,
    );
    return response.data;
  }

  Future<List<int>> getAsByte(
    String path,
  ) async {
    var response = await dio.get(
      path,
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data;
  }

  Future<List<int>> download(
    String path,
  ) async {
    var response = await dio.download(
      path,
      "",
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data;
  }

  /*
   * error统一处理
   */
  ErrorEntity createErrorEntity(DioError error) {
    switch (error.type) {
      case DioErrorType.cancel:
        {
          return ErrorEntity(code: -1, message: "请求取消");
        }
      case DioErrorType.connectTimeout:
        {
          return ErrorEntity(code: -1, message: "连接超时");
        }
      case DioErrorType.sendTimeout:
        {
          return ErrorEntity(code: -1, message: "请求超时");
        }

      case DioErrorType.receiveTimeout:
        {
          return ErrorEntity(code: -1, message: "响应超时");
        }
      case DioErrorType.response:
        {
          try {
            int? errCode = error.response?.statusCode;
            if (errCode == null) {
              return ErrorEntity(code: -2, message: error.message);
            }
            switch (errCode) {
              case 400:
                {
                  return ErrorEntity(
                      code: errCode,
                      message: error.response?.data['message'] ?? "请求语法错误");
                }

              case 401:
                {
                  return ErrorEntity(
                      code: errCode,
                      message: error.response?.data['message'] ?? "没有权限");
                }

              case 403:
                {
                  return ErrorEntity(
                      code: errCode,
                      message: error.response?.data['message'] ?? "服务器拒绝执行");
                }
              case 404:
                {
                  return ErrorEntity(code: errCode, message: "无法连接服务器");
                }
              case 405:
                {
                  return ErrorEntity(
                      code: errCode,
                      message: error.response?.data['message'] ?? "请求方法被禁止");
                }
              case 500:
                {
                  return ErrorEntity(code: errCode, message: "服务器内部错误");
                }
              case 502:
                {
                  return ErrorEntity(code: errCode, message: "无效的请求");
                }
              case 503:
                {
                  return ErrorEntity(
                      code: errCode,
                      message: error.response?.data['message'] ?? "服务器挂了");
                }
              case 505:
                {
                  return ErrorEntity(
                      code: errCode,
                      message:
                          error.response?.data['message'] ?? "不支持HTTP协议请求");
                }
              default:
                {
                  return ErrorEntity(
                      code: errCode, message: error.response?.data['message']);
                }
            }
          } on Exception catch (_) {
            return ErrorEntity(code: -1, message: "未知错误");
          }
        }
      default:
        {
          return ErrorEntity(code: -1, message: error.message);
        }
    }
  }
}

// 异常处理
class ErrorEntity implements Exception {
  int code;
  String? message;

  ErrorEntity({required this.code, this.message});

  String toString() {
    if (message == null) return "Exception";
    return "Exception: code $code, $message";
  }
}
