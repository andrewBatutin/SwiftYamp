//
//  BaseFrame.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/12/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import Foundation

enum FrameType : Int8 {
    
    case Handshake = 0x00
    case Pign = 0x01
    case Pong = 0x02
    case Close = 0x03
    case Close_Redirect = 0x04
    case Event = 0x05
    case Request = 0x06
    case Cancel = 0x07
    case Response = 0x08
}

struct BaseFrame {
    
    let type:FrameType;
    
}

