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

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var socket = WebSocket(url: URL(string: "ws://localhost:8080/")!)
        //websocketDidConnect
        socket.onConnect = {
            print("websocket is connected")
        }
        //websocketDidDisconnect
        socket.onDisconnect = { (error: NSError?) in
            print("websocket is disconnected: \(error?.localizedDescription)")
        }
        //websocketDidReceiveMessage
        socket.onText = { (text: String) in
            print("got some text: \(text)")
        }
        //websocketDidReceiveData
        socket.onData = { (data: Data) in
            print("got some data: \(data.count)")
        }
        //you could do onPong as well.
        socket.connect()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

