//
//  ViewController.swift
//  SwiftYampTester
//
//  Created by Andrey Batutin on 6/15/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import UIKit
import Starscream
import SwiftYamp
import ByteBackpacker

class ViewController: UIViewController {
    var d:Data = Data()
    var socket:WebSocket?

    @IBAction func onConnectButton(_ sender: Any) {
        //you could do onPong as well.
        socket?.connect()
    }
    
    @IBAction func onDisconnectButton(_ sender: Any) {
        socket?.disconnect()
    }
    
    @IBAction func onSendButton(_ sender: Any) {
        
        let h = HandshakeFrame(version: 1, size: 4, serializer: "json")
        
        socket?.write(data: try! h.toData())
        //socket?.write(data:Data(bytes: [0x00, 0x00, 0x01, 0x01, 0x41]))
        
        //socket?.write(data:Data(bytes: [0x00]))
        //socket?.write(data:Data(bytes: [0x00, 0x01]))
        //socket?.write(data:Data(bytes: [0x04]))
        //socket?.write(data:Data(bytes: [0x6a, 0x73, 0x6f, 0x6e]))
    }
    
    @IBAction func onPingButton(_ sender: Any) {
        
        let p = PingFrame(size: 4, payload: "DEAD")
        socket?.write(data: try! p.toData())
        
    }
    
    @IBAction func onCloseButton(_ sender: Any) {
        let c = CloseFrame(size:1, reason: "D")
        socket?.write(data: try! c.toData())
    }
    
    
    @IBAction func onCloseRedirectButton(_ sender: Any) {
        let cr = CloseRedirectFrame(size: 1, url: "A")
        socket?.write(data: try! cr.toData())
    }
    
    @IBAction func onSendRequestButton(_ sender: Any) {
        let h = UserMessageHeaderFrame(uid: [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], size: 3, uri: "mul")
        let b = UserMessageBodyFrame(size: 16, body: [0x7b, 0x22, 0x74, 0x65, 0x73, 0x74, 0x22, 0x3a, 0x20, 0x22, 0x74, 0x65, 0x73, 0x74, 0x22, 0x7d])
        let r = RequestFrame(header: h, isProgressive: false, body: b)
        socket?.write(data: try! r.toData())
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        socket = WebSocket(url: URL(string: "ws://localhost:8888")!)
        
        socket?.onConnect = {
            print("websocket is connected")
        }
        //websocketDidDisconnect
        socket?.onDisconnect = { (error: NSError?) in
            print("websocket is disconnected: \(error?.localizedDescription)")
        }
        //websocketDidReceiveMessage
        socket?.onText = { (text: String) in
            print("got some text: \(text)")
        }
        //websocketDidReceiveData
        socket?.onData = { (data: Data) in
            print("got some data: \(data.count)")
            self.d.append(data)
            //let res = try! deserialize(data: data) as! HandshakeFrame
            //print(res)
            do{
                let res = try deserialize(data: self.d)
                print(res)
                self.d = Data()
            }catch _{
                
            }
            
        }
        
    }

}

