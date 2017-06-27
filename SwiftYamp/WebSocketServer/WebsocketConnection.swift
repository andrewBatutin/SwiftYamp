//
//  WebsocketConnection.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/19/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import Foundation
import Starscream
import CocoaLumberjack

public class WebSocketConnection: YampConnection, YampMessageConnection, YampConnectionCallback, YampDataCallback{
    
    public var onConnect: ((Void)->Void)?
    public var onClose: ((String, CloseCodeType)->Void)?
    public var onRedirect: ((Void) -> String)?
    public var onEvent: ((EventFrame)->Void)?
    public var onResponse: ((ResponseFrame)->Void)?
    public var onPong: ((Data?) -> Void)?
    var onDataReceived: ((Data?) -> Void)?
    var onDataSend: ((Data?) -> Void)?
    private var data:Data = Data()
    public var versionSupported:[UInt16] =  [0x01]
    public private(set) var webSocket:WebSocket?
    
    public init?(url: String){
        guard let serverUrl = URL(string: url) else {
            return nil
        }
        webSocket = self.setupTransport(url: serverUrl)
    }
    
    private func setupTransport(url: URL) -> WebSocket{
        let webSocket = WebSocket(url: url)
        webSocket.onData = self.incomingDataHandler()
        webSocket.onConnect = { [unowned self] in
            let handshakeFrame = HandshakeFrame(version: self.versionSupported.last ?? 0x1)
            self.sendFrame(frame: handshakeFrame)
        }
        webSocket.onDisconnect = {[unowned self] (error)in
            let c = CloseFrame(closeCode: .Unknown, message: error?.localizedDescription)
            self.closeReceived(frame: c)
        }
        return webSocket
    }
    
    private func incomingDataHandler() -> ((Data) -> Void)?{
        self.data = Data()
        return { [unowned self] (data: Data) in
            self.data.append(data)
            do{
                let frame:YampTypedFrame = try deserialize(data: self.data) as! YampTypedFrame
                self.onDataReceived?(self.data)
                self.handleFrame(frame: frame)
                self.data = Data()
            }catch(let exp){
                DDLogWarn(exp.localizedDescription)
            }
        }
    }
    
    func handleFrame(frame:YampTypedFrame){
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
            DDLogInfo("we've got some unxpected frame \(frame.frameType)")
        }
    }

    func handshakeReceived(frame: HandshakeFrame){
        let v = frame.version
        
        if let str = self.onRedirect?() {
            self.cancel(reason: str, closeCode: .Redirect)
            self.onClose?("Redirect to \(str)", .Redirect)
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
        self.onClose?(frame.message, frame.closeCode)
        switch frame.closeCode {
        case .Timeout:
            self.disconnect()
        case .Redirect:
            self.reconnect(url: frame.message)
        default:
            DDLogInfo("close with code \(frame.closeCode)")
        }
        
    }
    
    public func reconnect(url: String){
        self.disconnect()
        guard let serverUrl = URL(string: url) else {
            return
        }
        self.webSocket = self.setupTransport(url: serverUrl)
        self.connect()
    }
    
    private func disconnect(){
        self.webSocket?.disconnect()
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
            DDLogError(exp.localizedDescription)
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
    
    public func sendEvent(uri: String, message: String){
        guard let data = message.data(using: .utf8) else {
            DDLogError("Error converting string to data")
            return
        }
        let h = UserMessageHeaderFrame(uid: messageUuid(), size: UInt8(uri.characters.count), uri: uri)
        let b = UserMessageBodyFrame(size: UInt32(data.count), body: data.toByteArray())
        let r = EventFrame(header: h, body: b)
        self.sendFrame(frame: r)
    }
    
    public func sendMessage(uri: String, message: String) {
        guard let data = message.data(using: .utf8) else {
            DDLogError("Error converting string to data")
            return
        }
        self.sendData(uri: uri, data: data)
    }
    
    public func timeout(){
        self.onClose?("Timeout", .Timeout)
        self.cancel(reason: "Timeout", closeCode: .Timeout)
    }
    

}
