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
        
        let h = HandshakeFrame(version: 1, size: 4, serializer: "test")
        
        //socket?.write(data: try! h.toData())
        //socket?.write(data:Data(bytes: [0x00, 0x00, 0x01, 0x01, 0x41]))
        
        socket?.write(data:Data(bytes: [0x00]))
        socket?.write(data:Data(bytes: [0x00, 0x01]))
        socket?.write(data:Data(bytes: [0x04]))
        socket?.write(data:Data(bytes: [0x6a, 0x73, 0x6f, 0x6e]))
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
            let r = try? deserialize(data: self.d)
            print(r)
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
            
            
        }
        
    }

}

