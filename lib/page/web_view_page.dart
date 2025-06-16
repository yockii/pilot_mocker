import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewPage extends StatefulWidget {
  final String url;

  const WebViewPage({super.key, required this.url});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  String _title = '第三方云';

  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    // iframeAllow: "camera; microphone",
    iframeAllowFullscreen: true,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: const Color.fromARGB(255, 233, 233, 233),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 60,
              color: Colors.white,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    style: ButtonStyle(iconSize: WidgetStateProperty.all(24)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(_title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.autorenew),
                        style: ButtonStyle(iconSize: WidgetStateProperty.all(24)),
                        onPressed: () {
                          webViewController?.reload();
                        },
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          // 弹出对话框确认注销
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('确认注销'),
                                content: const Text('注销后您的数据将不再同步至云端。是否注销？'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('取消'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // TODO 执行注销操作
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('确认', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        style: ButtonStyle(
                          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                          ),
                          backgroundColor: WidgetStateProperty.all(Colors.black),
                          foregroundColor: WidgetStateProperty.all(Colors.white),
                        ),
                        child: const Text('注销'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 1),
            Expanded(
              child: InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                initialSettings: settings,
                initialUserScripts: UnmodifiableListView([
                  UserScript(
                    source: """window.djiBridge = {
    _uuid: '',
    _isVerified: false,
    _loadedComponents: [],
    _token: '',

    platformSetWorkspaceId(uuid) {
        _uuid = uuid;
        return '{"code":0,"message":"ok","data":{}}';
    },
    platformSetInformation(platformName, workspaceName, desc) {
        window.flutter_inappwebview.callHandler('platformSetInformation', platformName, workspaceName, desc)
        return '{"code":0,"message":"ok","data":{}}';
    },
    platformGetRemoteControllerSN() {
        return '{"code":0,"message":"ok","data":{"sn":"RC123456789"}}';
    },
    platformGetRemoteControllerEnum() {
        return '{"code":0,"message":"ok","data":{"enum":["RC1", "RC2", "RC3"]}}';
    },
    platformGetProductEnum() {
        return '{"code":0,"message":"ok","data":{"enum":["Mavic Air 2", "Phantom 4 Pro", "Inspire 2"]}}';
    },
    platformGetAircraftSN() {
        return '{"code":0,"message":"ok","data":{"sn":"AC123456789"}}';
    },
    platformStartLogin() {
        return '{"code":0,"message":"ok","data":{}}';
    },
    platformStopSelf()  {
        window.flutter_inappwebview.callHandler('platformStopSelf')
        return '{"code":0,"message":"ok","data":{}}';
    },
    platformSetLogEncryptKey(key)  {
        return '{"code":0,"message":"ok","data":{}}';
    },
    platformClearLogEncryptKey()  {
        return '{"code":0,"message":"ok","data":{}}';
    },
    platformGetLogPath() {
        return '{"code":0,"message":"ok","data":"/path/to/log"}';
    },
    platformGetVersion() {
        return '{"code":0,"message":"ok","data":{"modelVersion": "01.00.00", "appVersion":"10.0.0.0"}}';
    },
    platformIsVerified() {
    debugger
        return '{"code":0,"message":"ok","data": ' + this._isVerified + '}';
    },
    platformVerifyLicense(appId, appKey, appLicense) {
        window.flutter_inappwebview.callHandler('platformVerifyLicense', appId, appKey, appLicense);
        return '{"code":0,"message":"ok","data":true}';
    },
    platformLoadComponent(name, param) {
        window.flutter_inappwebview.callHandler('platformLoadComponent', name, param);
        return '{"code":0,"message":"ok","data":true}';
    },
    platformUnloadComponent(name) {
        window.flutter_inappwebview.callHandler('platformUnloadComponent', name);
        return '{"code":0,"message":"ok","data":true}';
    },
    platformIsComponentLoaded(name) {
        return '{"code":0,"message":"ok","data":' + _loadedComponents.includes(name) + '}';
    },
    platformIsAppInstalled(appId) {
        return '{"code":0,"message":"ok","data":false}';
    },
    platformGetToken() {
        if (this._token) {
            return '{"code":0,"message":"ok","data":{"token": "' + this._token + '"}}';
        } else {
            return '{"code":-1,"message":"user not login"}';
        }
    },

    ///// thing
    _mqttConnectState: false,
    _userName: '',
    _passwd: '',
    _thingCallback: '',

    thingGetConnectState() {
        return '{"code":0,"message":"ok","data":' + this._mqttConnectState + '}';
    },
    thingConnect(userName, passwd, callback) {
        window.flutter_inappwebview.callHandler('thingConnect', userName, passwd, callback);
        return '{"code":0,"message":"ok","data":true}';
    },
    thingDisconnect() {
        window.flutter_inappwebview.callHandler('thingDisconnect');
        return '{"code":0,"message":"ok","data":true}';
    },
    thingSetConnectCallback(callback) {
        return '{"code":0,"message":"ok","data":true}';
    },
    thingGetConfigs() {
        return '{"code":0,"message":"ok","data":{"userName": "' + this._userName + '", "passwd": "' + this._passwd + '", "callback": "' + this._thingCallback + '"}}';
    },

    ///// api
    _host: '',
    apiSetToken(token) {
        this._token = token;
        window.flutter_inappwebview.callHandler('apiSetToken', token);
        return '{"code":0,"message":"ok","data":true}';
    },
    apiGetToken() {
        if (this._token) {
            return '{"code":0,"message":"ok","data":{"token": "' + this._token + '"}}';
        } else {
            return '{"code":-1,"message":"user not login"}';
        }
    },
    apiGetHost() {
        return '{"code":0,"message":"ok","data":{"host": "' + this._host + '"}}';
    },

    ///// ws
    _wsConnectState: false,
    _wsHost: '',
    _wsCallback: '',
    wsGetConnectState() {
        return '{"code":0,"message":"ok","data":' + this._wsConnectState + '}';
    },
    wsConnect(host, token, callback) {
        window.flutter_inappwebview.callHandler('wsConnect', host, token, callback);
        return '{"code":0,"message":"ok","data":true}';
    },
    wsDisconnect() {
        window.flutter_inappwebview.callHandler('wsDisconnect');
        return '{"code":0,"message":"ok","data":true}';
    },
    wsSend(message) {
        // 发送消息到 WebSocket
        window.flutter_inappwebview.callHandler('wsSend', message);
        return '{"code":0,"message":"ok","data":true}';
    },
    wsSetConnectCallback(callback) {
        return '{"code":0,"message":"ok","data":true}';
    },
    wsReceive(data) {
        // 接收 WebSocket 消息
        return '{"code":0,"message":"ok","data":' + JSON.stringify(data) + '}';
    },
    wsGetConfigs() {
        return '{"code":0,"message":"ok","data":{"host": "' + this._wsHost + '", "token": "' + this._token + '", "callback": "' + this._wsCallback + '"}}';
    },

    ///// map

    ///// media

    ///// liveshare

    ///// mission

    ///// mop


}""",
                    injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
                    forMainFrameOnly: false,
                  ),
                ]),
                onWebViewCreated: (controller) {
                  // 注册 JavaScript 处理器
                  controller.addJavaScriptHandler(handlerName: 'platformSetInformation', callback: (data) {
                    // 设置平台名称
                    if (data.length >= 3) {
                      final platformName = data[0];
                      final workspaceName = data[1];
                      final desc = data[2];
                      print('Platform Name: $platformName, Workspace Name: $workspaceName, Description: $desc');
                    }
                  });
                  controller.addJavaScriptHandler(handlerName: 'platformStopSelf', callback: (data) {
                    // 退出webview平台
                  });
                  controller.addJavaScriptHandler(handlerName: 'platformLoadComponent', callback: (data) {
                    // 加载组件
                    if (data.isNotEmpty) {
                      final name = data[0];
                      final param = data.length > 1 ? data[1] : null;
                      print('Load Component: $name, Param: $param');
                    }
                  });
                  controller.addJavaScriptHandler(handlerName: 'platformUnloadComponent', callback: (data) {
                    // 卸载组件
                    if (data.isNotEmpty) {
                      final name = data[0];
                      print('Unload Component: $name');
                    }
                  });
                  controller.addJavaScriptHandler(handlerName: 'platformVerifyLicense', callback: (data) {
                    // 验证许可证
                    if (data.length >= 3) {
                      final appId = data[0];
                      final appKey = data[1];
                      final appLicense = data[2];
                      print('Verify License: App ID: $appId, App Key: $appKey, App License: $appLicense');
                    }
                  });
                  controller.addJavaScriptHandler(handlerName: 'platformLoadComponent', callback: (data) {
                    // 加载组件
                    if (data.isNotEmpty) {
                      final name = data[0];
                      final param = data.length > 1 ? data[1] : null;
                      print('Load Component: $name, Param: $param');
                    }
                  });
                  controller.addJavaScriptHandler(handlerName: 'platformUnloadComponent', callback: (data) {
                    // 卸载组件
                    if (data.isNotEmpty) {
                      final name = data[0];
                      print('Unload Component: $name');
                    }
                  });
                  controller.addJavaScriptHandler(handlerName: 'thingConnect', callback: (data) {
                    // 连接 MQTT
                    if (data.length >= 3) {
                      final userName = data[0];
                      final passwd = data[1];
                      final callback = data[2];
                      print('Thing Connect: UserName: $userName, Password: $passwd, Callback: $callback');
                    }
                  });
                  controller.addJavaScriptHandler(handlerName: 'thingDisconnect', callback: (data) {
                    // 断开 MQTT 连接
                    print('Thing Disconnect');
                  });
                  controller.addJavaScriptHandler(handlerName: 'apiSetToken', callback: (data) {
                    // 设置 API Token
                    if (data.isNotEmpty) {
                      final token = data[0];
                      print('API Set Token: $token');
                    }
                  });
                  controller.addJavaScriptHandler(handlerName: 'wsConnect', callback: (data) {
                    // 连接 WebSocket
                    if (data.length >= 3) {
                      final host = data[0];
                      final token = data[1];
                      final callback = data[2];
                      print('WebSocket Connect: Host: $host, Token: $token, Callback: $callback');
                    }
                  });
                  controller.addJavaScriptHandler(handlerName: 'wsDisconnect', callback: (data) {
                    // 断开 WebSocket 连接
                    print('WebSocket Disconnect');
                  });
                  controller.addJavaScriptHandler(handlerName: 'wsSend', callback: (data) {
                    // 发送 WebSocket 消息
                    if (data.isNotEmpty) {
                      final message = data[0];
                      print('WebSocket Send: Message: $message');
                    }
                  });



                  webViewController = controller;
                },
                onLoadStart: (controller, url) {
                  setState(() {
                    _title = '第三方云加载中...';
                  });
                },
                onLoadStop: (controller, url) async {
                  final title = await controller.getTitle() ?? '第三方云';
                  setState(() {
                    _title = title;
                  });
                },
                onConsoleMessage: (controller, consoleMessage) {
                  print('Console message: ${consoleMessage.message}');
                },
              ),
            ),







          ],
        ),
      ),
    );
  }
}
