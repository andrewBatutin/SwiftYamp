//
//  ViewController.swift
//  SwiftYampTester
//
//  Created by Andrey Batutin on 6/15/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import UIKit
import Starscream

class ViewController: UIViewController {
    
    var socket:WebSocket?

    @IBAction func onConnectButton(_ sender: Any) {
        //you could do onPong as well.
        socket?.connect()
    }
    
    @IBAction func onDisconnectButton(_ sender: Any) {
        socket?.disconnect()
    }
    
    @IBAction func onSendButton(_ sender: Any) {
        socket?.write(ping: Data())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        socket = WebSocket(url: URL(string: "http://192.168.190.163:1489")!)
        
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
        }
        
    }

}

