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
    public var onEvent: ((EventFrame)->Void)?
    public var onResponse: ((ResponseFrame)->Void)?
    public var onPong: ((Data?) -> Void)?
    var onData: ((Data?) -> Void)?
    let versionSupported:[UInt16] =  [0x01]
    let webSocket:WebSocket?
    
    public init?(url: String){
        guard let serverUrl = URL(string: url) else {
            return nil
        }
        
        webSocket = WebSocket(url: serverUrl)
        webSocket?.onData = { (data: Data) in
            self.d.append(data)
            do{
                let frame:YampTypedFrame = try deserialize(data: self.d) as! YampTypedFrame
                self.onData?(self.d)
                switch frame.frameType {
                case .Handshake:
                    self.handshakeReceived(frame: frame as! HandshakeFrame)
                case .Close:
                    let closeFrame:CloseFrame = frame as! CloseFrame
                    self.onClose?(closeFrame.message, closeFrame.closeCode)
                case .Ping:
                    let pingFrame = frame as! PingFrame
                    let pongFrame = PingFrame(ack: true, size:UInt8(pingFrame.payload.characters.count), payload: pingFrame.payload)
                    self.webSocket?.write(data: try pongFrame.toData())
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
        
        webSocket?.onConnect = {
            let handshakeFrame = HandshakeFrame(version: self.versionSupported.last ?? 0x1)
            do{
                self.webSocket?.write(data: try handshakeFrame.toData())
            }catch(let exp){
                print(exp)
            }
        }
        
        webSocket?.onDisconnect = {(error)in
            print("\(String(describing: error?.localizedDescription))")
        }
        
    }
    
    func handshakeReceived(frame: HandshakeFrame){
        let v = frame.version
        if ( self.versionSupported.contains(v) ){
            self.onConnect?()
        } else {
            self.cancel(reason: "Version Not Supported", closeCode: .VersionNotSupported)
            self.onClose?("Version Not Supported", .VersionNotSupported)
        }
        
    }
    
    public func connect() {
        webSocket?.connect()
    }
    
    public func cancel(reason: String?, closeCode: CloseCodeType) {
        let size = reason?.characters.count ?? 0
        let closeFrame = CloseFrame(closeCode: closeCode, size:UInt16(size), reason: reason)
        do{
            webSocket?.write(data: try closeFrame.toData())
        }catch(let exp){
            print(exp)
        }
    }
    
    func sendFrame(frame: YampFrame) {
        do{
            webSocket?.write(data: try frame.toData())
        }catch(let exp){
            print(exp)
        }
    }
    
    public func sendPing(payload: String?){
        do{
            let size = payload?.characters.count ?? 0
            let frame = PingFrame(ack: false, size: UInt8(size), payload: payload)
            webSocket?.write(data: try frame.toData())
        }catch(let exp){
            print(exp)
        }
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
