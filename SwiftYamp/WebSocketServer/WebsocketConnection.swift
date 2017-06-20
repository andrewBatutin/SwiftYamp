//
//  WebsocketConnection.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/19/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import Foundation
import Starscream

public class WebSocketConnection: YampConnection{
    var d:Data = Data()
    public var onConnect: ((Void)->Void)?
    public var onClose: ((String)->Void)?
    public var onEvent: ((EventFrame)->Void)?
    public var onResponse: ((ResponseFrame)->Void)?
    let version:UInt16 = 1
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
                switch frame.frameType {
                case .Handshake:
                    self.onConnect?()
                case .Close:
                    let closeFrame:CloseFrame = frame as! CloseFrame
                    self.onClose?(closeFrame.reason)
                case .Ping:
                    let pingFrame = frame as! PingFrame
                    let pongFrame = PingFrame(size:UInt8(pingFrame.payload.characters.count), payload: pingFrame.payload)
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
            let handshakeFrame = HandshakeFrame(version: self.version, size: 4, serializer: "json")
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
    
    public func connect() {
        webSocket?.connect()
    }
    
    public func disconnect(reason: String?) {
        let size = reason?.characters.count ?? 0
        let closeFrame = CloseFrame(size:UInt16(size), reason: reason)
        do{
            webSocket?.write(data: try closeFrame.toData())
        }catch(let exp){
            print(exp)
        }
    }
    
    public func sendFrame(frame: YampFrame) {
        do{
            webSocket?.write(data: try frame.toData())
        }catch(let exp){
            print(exp)
        }
    }
    
    public func sendPing(payload: String?){
        do{
            let size = payload?.characters.count ?? 0
            let frame = PingFrame(size: UInt8(size), payload: payload)
            webSocket?.write(data: try frame.toData())
        }catch(let exp){
            print(exp)
        }
    }
    
    

}
