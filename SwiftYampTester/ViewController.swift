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
        socket?.cancel(reason: "close")
    }
    
    @IBAction func onSendRequestButton(_ sender: Any) {
        socket?.sendMessage(uri: "uri", message: "Test")
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

