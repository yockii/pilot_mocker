window.djiBridge = {
    ///// platform
    _uuid: '',
    _isVerified: false,
    _loadedComponents: new Set(),
    ///// thing
    _mqttConnectState: false,
    _mqttHost: '',
    _userName: '',
    _passwd: '',
    _thingCallback: '',
    ///// api
    _apiHost: '',
    _apiToken: '',
    ///// ws
    _wsConnectState: false,
    _wsHost: '',
    _wsToken: '',
    _wsCallback: '',

    ///// platform
    platformSetWorkspaceId(uuid) {
        this._uuid = uuid;
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
        return '{"code":0,"message":"ok","data":' + this._loadedComponents.includes(name) + '}';
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


}