//
//  BaseFrame.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/12/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import Foundation
import ByteBackpacker

protocol YampFrame {
    func toData() throws -> Data
}

enum ResponseType: UInt8 {
    
    case done = 0x00
    case error = 0x01
    case progress = 0x02
    case cancelled = 0x03
    
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

struct EventFrame {
    
    let type:BaseFrame = BaseFrame(type: FrameType.Event)
    let header:UserMessageHeaderFrame
    let body:UserMessageBodyFrame
    
}

struct RequestFrame {
    
    let type:BaseFrame = BaseFrame(type: FrameType.Request)
    let header:UserMessageHeaderFrame
    let isProgressive:Bool
    let body:UserMessageBodyFrame
    
}

struct CancelFrame {
    
    let type:BaseFrame = BaseFrame(type: FrameType.Cancel)
    let header:UserMessageHeaderFrame
    let requestUid:[UInt8]
    let kill:Bool
    
}

struct ResponseFrame {
    
    let type:BaseFrame = BaseFrame(type: FrameType.Response)
    let header:UserMessageHeaderFrame
    let requestUid:[UInt8]
    let responseType:ResponseType
    let body:UserMessageBodyFrame
    
}
