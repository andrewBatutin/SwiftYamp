//
//  YampConnection.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/19/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import Foundation

protocol YampDataCallback {
    var onDataReceived: ((Data?) -> Void)? {get set}
    var onDataSend: ((Data?) -> Void)? {get set}
}

protocol YampConnectionCallback {
    var onConnect: ((Void) -> Void)? {get set}
    var onClose: ((String, CloseCodeType) -> Void)? {get set}
    var onRedirect: ((Void) -> String)? {get set}
    var onEvent: ((EventFrame)->Void)? {get set}
    var onResponse: ((ResponseFrame)->Void)? {get set}
    var onPong: ((Data?) -> Void)? {get set}
}

protocol YampConnection {
    func connect()
    func timeout()
    func cancel(reason: String?, closeCode: CloseCodeType)
    func sendFrame(frame: YampFrame)
    func sendPing(payload: String?)
}

protocol YampMessageConnection {
    func sendMessage(uri: String, message: String)
    func sendData(uri: String, data: Data)
}
