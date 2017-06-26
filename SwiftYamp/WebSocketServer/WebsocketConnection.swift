//
//  WebsocketConnection.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/19/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import Foundation
import Starscream

public class WebSocketConnection: YampConnection, YampMessageConnection, YampConnectionCallback, YampDataCallback{
    var d:Data = Data()
    public var onConnect: ((Void)->Void)?
    public var onClose: ((String, CloseCodeType)->Void)?
    public var onRedirect: ((Void) -> String)?
    public var onEvent: ((EventFrame)->Void)?
    public var onResponse: ((ResponseFrame)->Void)?
    public var onPong: ((Data?) -> Void)?
    var onDataReceived: ((Data?) -> Void)?
    var onDataSend: ((Data?) -> Void)?
    let versionSupported:[UInt16] =  [0x01]
    var webSocket:WebSocket?
    
    public init?(url: String){
        guard let serverUrl = URL(string: url) else {
            return nil
        }
        webSocket = self.setupTransport(url: serverUrl)
    }
    
    private func setupTransport(url: URL) -> WebSocket{
        let webSocket = WebSocket(url: url)
        webSocket.onData = self.incomingDataHandler()
        webSocket.onConnect = {
            let handshakeFrame = HandshakeFrame(version: self.versionSupported.last ?? 0x1)
            self.sendFrame(frame: handshakeFrame)
        }
        webSocket.onDisconnect = {(error)in
            print("\(String(describing: error?.localizedDescription))")
        }
        return webSocket
    }
    
    private func incomingDataHandler() -> ((Data) -> Void)?{
        return { (data: Data) in
            self.d.append(data)
            do{
                let frame:YampTypedFrame = try deserialize(data: self.d) as! YampTypedFrame
                self.onDataReceived?(self.d)
                switch frame.frameType {
                case .Handshake:
                    self.handshakeReceived(frame: frame as! HandshakeFrame)
                case .Close:
                    let closeFrame:CloseFrame = frame as! CloseFrame
                    self.closeReceived(frame: closeFrame)
                case .Ping:
                    let pingFrame = frame as! PingFrame
                    let pongFrame = PingFrame(ack: true, size:UInt8(pingFrame.payload.characters.count), payload: pingFrame.payload)
                    self.sendFrame(frame: pongFrame)
                case .Event:
                    self.onEvent?(frame as! EventFrame)
                case .Response:
                    self.onResponse?(frame as! ResponseFrame)
                default:
                    print("ops")
                }
                self.d = Data()
            }catch(let exp){
                print(exp)
            }
        }

    }
    

    func handshakeReceived(frame: HandshakeFrame){
        let v = frame.version
        
        if let s = self.onRedirect?() {
            self.cancel(reason: s, closeCode: .Redirect)
            self.onClose?("Redirect to \(s)", .Redirect)
            return
        }
        
        if ( self.versionSupported.contains(v) ){
            self.onConnect?()
        } else {
            self.cancel(reason: "Version Not Supported", closeCode: .VersionNotSupported)
            self.onClose?("Version Not Supported", .VersionNotSupported)
        }
    }
    
    func closeReceived(frame: CloseFrame){
        
        switch frame.closeCode {
        case .Redirect:
            self.onClose?(frame.message, frame.closeCode)
            self.reconnect(url: frame.message)
        default:
            self.onClose?(frame.message, frame.closeCode)
        }
        
    }
    
    public func reconnect(url: String){
        self.webSocket?.disconnect()
        guard let serverUrl = URL(string: url) else {
            return
        }
        self.webSocket = self.setupTransport(url: serverUrl)
        self.connect()
    }
    
    public func connect() {
        webSocket?.connect()
    }
    
    public func cancel(reason: String?, closeCode: CloseCodeType) {
        let closeFrame = CloseFrame(closeCode: closeCode, message: reason)
        self.sendFrame(frame: closeFrame)
    }
    
    func sendFrame(frame: YampFrame) {
        do{
            let data = try frame.toData()
            self.onDataSend?(data)
            webSocket?.write(data: data)
        }catch(let exp){
            print(exp)
        }
    }
    
    public func sendPing(payload: String?){
        let size = payload?.characters.count ?? 0
        let frame = PingFrame(ack: false, size: UInt8(size), payload: payload)
        self.sendFrame(frame: frame)
    }
    
    public func sendData(uri: String, data: Data) {
        let h = UserMessageHeaderFrame(uid: messageUuid(), size: UInt8(uri.characters.count), uri: uri)
        let b = UserMessageBodyFrame(size: UInt32(data.count), body: data.toByteArray())
        let r = RequestFrame(header: h, body: b)
        self.sendFrame(frame: r)
    }
    
    public func sendMessage(uri: String, message: String) {
        guard let data = message.data(using: .utf8) else {
            print("Error converting string to data")
            return
        }
        self.sendData(uri: uri, data: data)
    }
    
    public func timeout(){
        self.cancel(reason: "Timeout", closeCode: .Timeout)
        self.onClose?("Timeout", .Timeout)
    }
    

}
