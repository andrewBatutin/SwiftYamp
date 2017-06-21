//
//  YampConnection.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/19/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import Foundation

protocol YampConnection {
    func connect()
    func cancel(reason: String?)
    func sendFrame(frame: YampFrame)
    func sendPing(payload: String?)
}

protocol YampMessageConnection {
    func sendMessage(uri: String, message: String)
    func sendData(uri: String, data: Data)
}
