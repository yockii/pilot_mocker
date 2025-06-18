import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:pilot_mocker/client/ws.dart';
import 'package:pilot_mocker/model/api.dart';
import 'package:pilot_mocker/model/thing.dart';
import 'package:pilot_mocker/model/third_cloud.dart';
import 'package:pilot_mocker/model/ws.dart';
import 'package:pilot_mocker/client/mqtt.dart';
import 'package:provider/provider.dart';

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

  String injectJsSource = '';

  @override
  void initState() {
    super.initState();
    // 异步读取assets/js/inject.js后再渲染WebView
    rootBundle.loadString('assets/js/inject.js').then((source) {
      setState(() {
        injectJsSource = source;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final thirdCloud = Provider.of<ThirdCloudModel>(context, listen: false);
    final thing = Provider.of<ThingModel>(context, listen: false);
    final ws = Provider.of<WsModel>(context, listen: false);
    final api = Provider.of<ApiModel>(context, listen: false);

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
                  IconButton(icon: const Icon(Icons.arrow_back), style: ButtonStyle(iconSize: WidgetStateProperty.all(24)), onPressed: () async {
                    final r = await webViewController?.evaluateJavascript(source: "window.djiBridge.onBackClick();");
                    if (r == false ) {
                      Navigator.of(context).pop();
                    }
                  }),
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
                                    onPressed: () async {
                                      // 清除所有模型数据
                                      thirdCloud.clear();
                                      thing.clear();
                                      ws.clear();
                                      api.clear();
                                      // 清除webview中的localStorage数据
                                      await webViewController?.evaluateJavascript(source: "window.djiBridge.onStopPlatform();");
                                      // 关闭确认对话框
                                      Navigator.of(context).pop();
                                      // 返回上一个界面
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
                          shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0))),
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
              child: injectJsSource.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                initialSettings: settings,
                initialUserScripts: UnmodifiableListView([
                  UserScript(
                    source: injectJsSource,
                    injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
                    forMainFrameOnly: false,
                  ),
                ]),
                onWebViewCreated: (controller) {
                  // 注册 JavaScript 处理器
                  controller.addJavaScriptHandler(
                    handlerName: 'platformSetInformation',
                    callback: (data) {
                      // 设置平台名称
                      if (data.length >= 3) {
                        final platformName = data[0];
                        final workspaceName = data[1];
                        final desc = data[2];
                        thirdCloud.setAll(platformName, workspaceName, desc);
                      }
                    },
                  );
                  controller.addJavaScriptHandler(
                    handlerName: 'platformStopSelf',
                    callback: (data) {
                      // 退出webview平台
                      thirdCloud.clear();
                      thing.clear();
                      ws.clear();
                      api.clear();
                    },
                  );
                  controller.addJavaScriptHandler(
                    handlerName: 'platformLoadComponent',
                    callback: (data) async {
                      // 加载组件
                      if (data.isNotEmpty) {
                        final name = data[0];
                        final param = data.length > 1 ? data[1] : null;
                        switch (name) {
                          case 'thing':
                            // 处理 thing 组件加载, param字符串转化为 Map<String, String>
                            Map<String, dynamic> paramMap = param != null ? json.decode(param) : {};

                            // 获取参数
                            final host = paramMap['host'] ?? '';
                            final username = paramMap['username'] ?? '';
                            final password = paramMap['password'] ?? '';
                            final connectCallback = paramMap['connectCallback'] ?? '';
                            // 更新ThingModel
                            Provider.of<ThingModel>(context, listen: false).setAll(host, username, password, connectCallback);
                            await thingConnect(username, password, connectCallback);

                            await controller.evaluateJavascript(source: """
                              window.djiBridge._loadedComponents.add('thing');
                            """);


                            break;
                          case 'api':
                            // 处理 api 组件加载
                            Map<String, dynamic> paramMap = param != null ? json.decode(param) : {};
                            // 更新 ApiModel
                            Provider.of<ApiModel>(context, listen: false).setAll(paramMap['host'] ?? '', paramMap['token'] ?? '');
                            
                            await controller.evaluateJavascript(source: """
                              window.djiBridge._loadedComponents.add('api');
                              window.djiBridge._apiHost = '${paramMap['host']}';
                              window.djiBridge._apiToken = '${paramMap['token']}';
                            """);

                            break;
                          case 'ws':
                            Map<String, dynamic> paramMap = param != null ? json.decode(param) : {};
                            // 获取参数
                            final host = paramMap['host'] ?? '';
                            final token = paramMap['token'] ?? '';
                            final connectCallback = paramMap['connectCallback'] ?? '';
                            // 连接 WebSocket
                            await wsConnect(host, token, connectCallback);
                            await controller.evaluateJavascript(source: """
                              window.djiBridge._loadedComponents.add('ws');
                            """);
                            break;
                          default:
                            // 处理其他组件加载
                            print('Load Component: $name, Param: $param');
                        }

                        print('Load Component: $name, Param: $param');
                      }
                    },
                  );
                  controller.addJavaScriptHandler(
                    handlerName: 'platformUnloadComponent',
                    callback: (data) async {
                      // 卸载组件
                      if (data.isNotEmpty) {
                        final name = data[0];
                        switch (name) {
                          case 'thing':
                            // 处理 thing 组件卸载
                            Provider.of<ThingModel>(context, listen: false).clear();
                            await controller.evaluateJavascript(source: """
                              window.djiBridge._loadedComponents.delete('thing');
                              window.djiBridge._thingCallback = '';
                              window.djiBridge._mqttHost = '';
                              window.djiBridge._userName = '';
                              window.djiBridge._passwd = '';
                            """);
                            break;
                          case 'api':
                            // 处理 api 组件卸载
                            Provider.of<ApiModel>(context, listen: false).clear();
                            await controller.evaluateJavascript(source: """
                              window.djiBridge._loadedComponents.delete('api');
                              window.djiBridge._apiHost = '';
                              window.djiBridge._apiToken = '';
                            """);
                            break;
                          case 'ws':
                            // 处理 WebSocket 组件卸载
                            Provider.of<WsModel>(context, listen: false).clear();
                            await controller.evaluateJavascript(source: """
                              window.djiBridge._loadedComponents.delete('ws');
                              window.djiBridge._wsHost = '';
                              window.djiBridge._wsToken = '';
                              window.djiBridge._wsCallback = '';
                            """);
                            break;
                          default:
                            // 处理其他组件卸载
                            print('Unload Component: $name');
                        }
                        await controller.evaluateJavascript(source: """
                          window.djiBridge._loadedComponents.delete('$name');
                        """);
                      }
                    },
                  );
                  controller.addJavaScriptHandler(
                    handlerName: 'platformVerifyLicense',
                    callback: (data) async {
                      // 验证许可证
                      if (data.length >= 3) {
                        final appId = data[0];
                        final appKey = data[1];
                        final appLicense = data[2];
                        print('Verify License: AppId: $appId, AppKey: $appKey, AppLicense: $appLicense');
                        await controller.evaluateJavascript(source: """
                          window.djiBridge._isVerified = true; // 模拟验证成功
                        """);
                      }
                    },
                  );
                  controller.addJavaScriptHandler(
                    handlerName: 'thingConnect',
                    callback: (data) async {
                      // 连接 MQTT
                      if (data.length >= 3) {
                        final userName = data[0];
                        final passwd = data[1];
                        final callback = data[2];

                        await thingConnect(userName, passwd, callback);
                      }
                    },
                  );
                  controller.addJavaScriptHandler(
                    handlerName: 'thingDisconnect',
                    callback: (data) {
                      // 断开 MQTT 连接
                      MqttClientSingleton().disconnect();
                      // 更新 JavaScript 状态
                      controller.evaluateJavascript(source: """
                        window.djiBridge._mqttConnectState = false;
                        window.djiBridge._thingCallback = null;
                        window.djiBridge._userName = null;
                        window.djiBridge._passwd = null;
                      """);
                    },
                  );
                  controller.addJavaScriptHandler(
                    handlerName: 'apiSetToken',
                    callback: (data) {
                      // 设置 API Token
                      if (data.isNotEmpty) {
                        final token = data[0];
                        api.setToken(token);
                        // 更新 JavaScript 状态
                        controller.evaluateJavascript(source: """
                          window.djiBridge._apiToken = '$token';
                        """);
                      }
                    },
                  );
                  controller.addJavaScriptHandler(
                    handlerName: 'wsConnect',
                    callback: (data) async {
                      // 连接 WebSocket
                      if (data.length >= 3) {
                        final host = data[0];
                        final token = data[1];
                        final callback = data[2];
                        await wsConnect(host, token, callback);
                      }
                    },
                  );
                  controller.addJavaScriptHandler(
                    handlerName: 'wsDisconnect',
                    callback: (data) async {
                      // 断开 WebSocket 连接
                      final wsClient = WebSocketClient();
                      await wsClient.disconnect();
                      // 更新 JavaScript 状态
                      controller.evaluateJavascript(source: """
                        window.djiBridge._wsConnectState = false;
                      """);
                    },
                  );
                  controller.addJavaScriptHandler(
                    handlerName: 'wsSend',
                    callback: (data) {
                      // 发送 WebSocket 消息
                      if (data.isNotEmpty) {
                        final message = data[0];
                        final wsClient = WebSocketClient();
                        if (wsClient.isConnected) {
                          wsClient.send(message);
                        }
                      }
                    },
                  );

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

  Future<void> thingConnect(String userName, String passwd, String callback) async {
    final thing = Provider.of<ThingModel>(context, listen: false);
    await MqttClientSingleton().connect(
      url: thing.host,
      clientId: '',
      username: userName,
      password: passwd,
    );
    // 连接成功后更新状态
    thing.setConnectCallback(callback);
    thing.setUsername(userName);
    thing.setPassword(passwd);
    thing.setHost(thing.host);
    // 更新 JavaScript 状态，同时回调window.[callback]方法
    webViewController?.evaluateJavascript(source: """
      window.djiBridge._mqttConnectState = true;
      window.djiBridge._thingCallback = '$callback';
      window.djiBridge._userName = '$userName';
      window.djiBridge._passwd = '$passwd';
      window.$callback && window.$callback();
    """);
  }

  Future<void> wsConnect(String host, String token, String callback) async {
    final ws = Provider.of<WsModel>(context, listen: false);
    final wsClient = WebSocketClient();
    if (wsClient.isConnected) {
      await wsClient.disconnect();
    }
    wsClient.setHost(host);
    wsClient.setToken(token);
    await wsClient.connect();
    // 更新状态
    ws.setAll(host, token, callback);
    // 更新 JavaScript 状态，同时回调window.[callback]方法
    webViewController?.evaluateJavascript(source: """
      window.djiBridge._wsConnectState = true;
      window.djiBridge._wsHost = '$host';
      window.djiBridge._wsToken = '$token';
      window.djiBridge._wsCallback = '$callback';
      window.$callback && window.$callback();
    """);
  }
}
