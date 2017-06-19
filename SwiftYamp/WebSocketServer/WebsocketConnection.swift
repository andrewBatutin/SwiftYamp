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
    var onConnect: (Void)->Void?
    let version:UInt16 = 1
    let webSocket:WebSocket?
    
    public init?(url: String){
        guard let serverUrl = URL(string: url) else {
            return nil
        }
        
        onConnect = {
            print("yamp connected")
        }
        
        webSocket = WebSocket(url: serverUrl)
        webSocket?.onData = { (data: Data) in
            self.d.append(data)
            do{
                
                
                let res:YampTypedFrame = try deserialize(data: self.d) as! YampTypedFrame
                
                switch res.frameType {
                case .Handshake:
                    self.onConnect()
                default:
                    print("ops")
                }
                
                self.d = Data()
            }catch(let exp){
                print(exp)
            }
        }
    }
    
    public func connect() {
        let h = HandshakeFrame(version: version, size: 4, serializer: "json")
        do{
            webSocket?.write(data: try h.toData())
        }catch(let exp){
            print(exp)
        }
    }
    
    public func disconnect() {
        
    }
    
    public func sendFrame(frame: YampFrame) {
        
    }
    
    
    
    

}
