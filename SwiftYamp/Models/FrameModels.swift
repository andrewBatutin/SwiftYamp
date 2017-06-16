//
//  BaseFrame.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/12/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import Foundation
import ByteBackpacker

extension Bool {
    init<T : Integer>(_ integer: T){
        self.init(integer != 0)
    }
}

public protocol YampFrame {
    func toData() throws -> Data
}

public enum ResponseType: UInt8 {
    case Done = 0x00
    case Error = 0x01
    case Progress = 0x02
    case Cancelled = 0x03
}

enum FrameType : UInt8 {
    case Handshake = 0x00
    case Ping = 0x01
    case Pong = 0x02
    case Close = 0x03
    case Close_Redirect = 0x04
    case Event = 0x05
    case Request = 0x06
    case Cancel = 0x07
    case Response = 0x08
}

struct BaseFrame: Equatable, YampFrame { 
    let type:FrameType;
    
    static func ==(lhs: BaseFrame, rhs: BaseFrame) -> Bool {
        return lhs.type == rhs.type
    }
    
    func toData() throws -> Data{
        let r = ByteBackpacker.pack(self.type.rawValue)
        return Data(bytes: r)
    }
}
