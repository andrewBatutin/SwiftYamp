//
//  BaseFrame.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/12/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import Foundation

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

struct BaseFrame: Equatable {
    
    let type:FrameType;
    
    static func ==(lhs: BaseFrame, rhs: BaseFrame) -> Bool {
        return lhs.type == rhs.type
    }
    
}

struct HandshakeFrame {
    
    let type:BaseFrame = BaseFrame(type: FrameType.Handshake)
    let version:UInt16
    let size:UInt8
    let serialized:String
    
}

struct PingFrame {
    
    let type:BaseFrame = BaseFrame(type: FrameType.Ping)
    let size:UInt8
    var payload:String = "" // (optional)
    
    init(size: UInt8) {
        self.size = size
    }
    
    init(size: UInt8, payload: String) {
        self.size = size
        self.payload = payload
    }
    
}

struct PongFrame {
    
    let type:BaseFrame = BaseFrame(type: FrameType.Pong)
    let size:UInt8
    var payload:String = "" // (optional)
    
    init(size: UInt8) {
        self.size = size
    }
    
    init(size: UInt8, payload: String) {
        self.size = size
        self.payload = payload
    }
    
}

struct CloseFrame {
    
    let type:BaseFrame = BaseFrame(type: FrameType.Close)
    let size:UInt16
    var reason:String = "" // (optional)
    
    init(size: UInt16) {
        self.size = size
    }
    
    init(size: UInt16, reason: String) {
        self.size = size
        self.reason = reason
    }
    
}

struct CloseRedirectFrame {
    
    let type:BaseFrame = BaseFrame(type: FrameType.Close_Redirect)
    let size:UInt16
    let url:String
    
}

struct UserMessageHeaderFrame: Equatable {
    
    let uid:[UInt8]
    let size:UInt8
    let uri:String
    
    static func ==(lhs: UserMessageHeaderFrame, rhs: UserMessageHeaderFrame) -> Bool {
        return lhs.uid == rhs.uid && lhs.size == rhs.size && lhs.uri == rhs.uri
    }
    
}

struct UserMessageBodyFrame: Equatable {
    
    let size:UInt32
    var body:[UInt8]? // (optional) maximum 4Gb
    
    static func ==(lhs: UserMessageBodyFrame, rhs: UserMessageBodyFrame) -> Bool {
        let lBody = lhs.body ?? []
        let rBody = rhs.body ?? []
        return lhs.size == rhs.size && lBody == rBody
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
