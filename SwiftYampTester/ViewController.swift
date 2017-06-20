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
    var socket:WebSocketConnection?

    @IBAction func onConnectButton(_ sender: Any) {
        //you could do onPong as well.
        socket?.connect()
    }
    
    @IBAction func onPingButton(_ sender: Any) {
        socket?.sendPing(payload: "hi")
    }
    
    @IBAction func onCloseButton(_ sender: Any) {
        socket?.disconnect(reason: "close")
    }
    
    @IBAction func onSendRequestButton(_ sender: Any) {
        let h = UserMessageHeaderFrame(uid: [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], size: 3, uri: "mul")
        let b = UserMessageBodyFrame(size: 16, body: [0x7b, 0x22, 0x74, 0x65, 0x73, 0x74, 0x22, 0x3a, 0x20, 0x22, 0x74, 0x65, 0x73, 0x74, 0x22, 0x7d])
        let r = RequestFrame(header: h, body: b)
        socket?.sendFrame(frame: r)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        socket = WebSocketConnection(url: "ws://localhost:8888")!
        
        
        socket?.onConnect = {
            print("websocket is connected")
        }
        //websocketDidDisconnect
        socket?.onClose = { (reason: String?) in
            print("websocket is disconnected: \(String(describing: reason))")
        }
        //websocketDidReceiveMessage
        socket?.onResponse = { (response: ResponseFrame) in
            print("got some text: \(response)")
        }
        
    }

}

