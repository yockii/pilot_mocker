设备主动订阅主题
|Topic Name |订阅者
|----------------|----------------|
|thing/product/{gateway_sn}/state/set|设备|
|thing/product/{gateway_sn}/state/get|设备|
|thing/product/{gateway_sn}/services|设备|
|thing/product/{gateway_sn}/events_reply|设备|
|thing/product/{gateway_sn}/requests_reply|设备|
|thing/product/{gateway_sn}/network/probe|设备|
|thing/product/{gateway_sn}/status_reply|设备|

公共字段解析
参数名|名称|类型|说明
|----------------|----------------|----------------|----------------|
tid|消息ID| string|事务（Transaction）的UUID：表征⼀次简单的消息通信，如：增/删/改/查，云台控制等，可以是：1.数据上报请求+数据上报响应 2.握⼿认证请求+响应+ack 3.报警事件单向通知等，解决事务多并发和消匹配的问题
bid|业务uuid| string|业务（Business）的UUID：有些功能不是⼀次通信就能完成的，包含持续⼀段时间内的所有交互。业务通常由多个原⼦事务组成，且持续时间较长; 例如点播/下载/回放；解决业务多并发和重复请求的问题，便于所有模块的状态机管理。
gateway|网关设备序列号| string|发送该消息的网关设备的序列号
timestamp|毫秒时间戳| long|消息的发送时间
data|消息内容| object|消息内容

