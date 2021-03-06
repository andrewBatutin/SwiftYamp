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

public protocol YampTypedFrame{
    var frameType:FrameType {get}
}

public enum ResponseType: UInt8 {
    case Done = 0x00
    case Error = 0x01
    case Progress = 0x02
    case Cancelled = 0x03
}

public enum FrameType : UInt8 {
    case Handshake = 0x00
    case Close = 0x01
    case Ping = 0x02
    case Event = 0x10
    case Request = 0x11
    case Cancel = 0x12
    case Response = 0x13
}

struct BaseFrame: Equatable, YampFrame{
    let type:FrameType;
    
    static func ==(lhs: BaseFrame, rhs: BaseFrame) -> Bool {
        return lhs.type == rhs.type
    }
    
    func toData() throws -> Data{
        let r = ByteBackpacker.pack(self.type.rawValue)
        return Data(bytes: r)
    }
}
