//
//  WebSocketManager.swift
//  MXApp
//
//  Created by 华峰 on 2021/5/31.
//

import Foundation
import Starscream
import Alamofire

public enum WebSocketConnectType {
    case closed       //初始状态,未连接
    case connect      //已连接
    case disconnect   //连接后断开
    case reconnecting //重连中...
}

open class MXWebSocketManager: NSObject {
    /// 单例,可以使用单例,也可以使用[alloc]init 根据情况自己选择
    public static let shard = MXWebSocketManager()
    /// WebSocket对象
    private var webSocket : WebSocket?
    /// 是否连接
    public var isConnected : Bool = false

    private var heartbeatInterval: TimeInterval = 5
    
    //存储要发送给服务端的数据,本案例不实现此功能,如有需求自行实现
    private var sendDataArray = [String]()
    

    ///心跳包定时器
    var heartBeatTimer: Timer?
    
    var connectType : WebSocketConnectType = .closed
    /// 用于判断是否主动关闭长连接，如果是主动断开连接，连接失败的代理中，就不用执行 重新连接方法
    private var isActivelyClose:Bool = false
    
    /// 当前是否有网络,
    private var isHaveNet:Bool = true
    
    public var connectUrl: String?

    
    override init() {
        super.init()
    }
    
    deinit {
        // 移除通知
        NotificationCenter.default.removeObserver(self)
    }
    
    //建立长连接
    public func createWebScoketConnect() {
        MXAPI.APP.getWebSocketInfo { data, message, code in
            if code == 0 {
                if let dict = data as? [String: Any], let wbUrl = dict["url"] as? String {
                    MXWebSocketManager.shard.connectUrl = wbUrl
                }
                MXWebSocketManager.shard.disconnect()
                MXWebSocketManager.shard.connectSocket(nil)
            }
        }
    }
    
    // MARK: - 公开方法,外部调用
    func connectSocket(_ paremeters: Any?) {
        guard let urlStr = self.connectUrl, let url = URL(string: urlStr) else {
            return
        }
        guard let token = MXAccountModel.shared.token else {
            return
        }

        self.isActivelyClose = false

        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        
        //添加头信息
        request.setValue("headers", forHTTPHeaderField: "Cookie")
        request.setValue("CustomeDeviceInfo", forHTTPHeaderField: "DeviceInfo")
        request.setValue(token, forHTTPHeaderField: "Authorization")
        webSocket = WebSocket(request: request)
        webSocket?.delegate = self
        webSocket?.connect()
        // 自定义队列,一般不需要设置,默认主队列
        //webSocket?.callbackQueue = DispatchQueue(label: "com.vluxe.starscream.myapp")

    }
    /// 发送消息
    func sendMessage(_ text: String) {
        if !self.isActivelyClose {  //非主动断开
            if self.isHaveNet {
                // 有网络直接发消息
                if self.connectType == .connect {  //已经连接
                    self.webSocket?.write(string: text)
                }else if self.connectType == .disconnect {
                    //
                    self.connectSocket(nil)
                }else{
                    self.sendDataArray.append(text)
                }
                
            } else {
                // 无网络的时候的操作
                //1.提示无网络
                //2.存储消息
                self.sendDataArray.append(text)
            }
        }
    }
    /// 断开链接
    public func disconnect() {
        self.isActivelyClose = true
        self.connectType = .disconnect
        webSocket?.disconnect()
        destoryHeartBeat()
    }
    
    // MARK: - 私有方法
    /// 初始化心跳
    private func initHeartBeat() {
        
        if self.heartBeatTimer != nil {
            return
        }
        self.heartBeatTimer = Timer(timeInterval: 30, target: self, selector: #selector(sendHeartBeat), userInfo: nil, repeats: true)
        RunLoop.current.add(self.heartBeatTimer!, forMode: RunLoop.Mode.common)
    }
    
    /// 心跳
    @objc private func sendHeartBeat() {
        if self.isConnected {
            let text = "我是心跳"
            if let data = text.data(using: String.Encoding.utf8) {
                webSocket?.write(ping: data)
            }
            
            // 我在网上查阅资料显示,也可以使用webSocket?.write(string: "")
            // 即: webSocket?.write(string: text)
            // write方法中ping和text是一样的,只是传入的枚举不一样,可以参考源代码
        }else{
            // 发现没有连接,根据需求做判断
            self.connectSocket(nil)
        }
    }
    
    //关闭心跳定时器
    private func destoryHeartBeat() {
        self.heartBeatTimer?.invalidate()
        self.heartBeatTimer = nil
    }
    
}

extension MXWebSocketManager: WebSocketDelegate{
    public func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
            case .connected(let headers):
                isConnected = true
                //开始发送websocket心跳
                self.initHeartBeat()
                //_ = "连接成功,在这里处理成功后的逻辑,比如将发送失败的消息重新发送等等..."
           mxAppLog("[MXWebSocket]: connected: \(headers)")
                break
            case .disconnected(let reason, let code):
                isConnected = false
                self.connectType = .disconnect
                if self.isActivelyClose {
                    self.connectType = .closed
                } else {
                    self.connectType = .disconnect
                    destoryHeartBeat() //断开心跳定时器
                    if self.isHaveNet {  //存在网络重连
                        self.connectSocket(nil)
                    }
                }
               mxAppLog("[WebSocket] disconnected: \(reason) with code: \(code)")
                break
            case .text(let string):
                MXHomeManager.shard.receiveMessageHander(text: string)
               mxAppLog("[WebSocket] Received text: \(string)")
                break
            case .binary(let data):
               mxAppLog("[WebSocket] Received data: \(data.count)")
                break
            case .ping(_):
               mxAppLog("[WebSocket] ping")
                break
            case .pong(_):
               mxAppLog("[WebSocket] pong")
                break
            case .viabilityChanged(_):
               mxAppLog("[WebSocket] viabilityChanged")
                break
            case .reconnectSuggested(_):
               mxAppLog("[WebSocket] reconnectSuggested")
                break
            case .cancelled:
               mxAppLog("[WebSocket] cancelled")
                isConnected = false
                if !self.isActivelyClose {
                    if self.isHaveNet {  //存在网络重连
                        self.connectSocket(nil)
                    }
                }
                break
            case .error(let error):
               mxAppLog("[WebSocket] error")
                isConnected = false
                if !self.isActivelyClose {
                    if self.isHaveNet {  //存在网络重连
                        self.connectSocket(nil)
                    }
                }
                handleError(error)
                break
            default :
               mxAppLog("[MXWebSocket]: peerClosed: error")
                break
        }
    }
    
    // custom
    func handleError(_ error: Error?) {
        if let e = error as? WSError {
           mxAppLog("[MXWebSocket]: websocket encountered an error: \(e.message)")
        } else if let e = error {
           mxAppLog("[MXWebSocket]: websocket encountered an error: \(e.localizedDescription)")
        } else {
           mxAppLog("[MXWebSocket]: websocket encountered an error")
        }
    }
}
