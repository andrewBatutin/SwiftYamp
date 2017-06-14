//
//  RequestFrame.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/14/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import Foundation
import ByteBackpacker

extension Bool {
    init<T : Integer>(_ integer: T){
        self.init(integer != 0)
    }
}

struct RequestFrame: Equatable, YampFrame {
    
    let type:BaseFrame = BaseFrame(type: FrameType.Request)
    let header:UserMessageHeaderFrame
    let isProgressive:Bool
    let body:UserMessageBodyFrame
    
    static func ==(lhs: RequestFrame, rhs: RequestFrame) -> Bool {
        return lhs.type == rhs.type && lhs.header == rhs.header && lhs.isProgressive == rhs.isProgressive && lhs.body == rhs.body
    }
    
    init(header: UserMessageHeaderFrame, isProgressive: Bool, body: UserMessageBodyFrame) {
        self.header = header
        self.isProgressive = isProgressive
        self.body = body
    }
    
    init(data: Data) throws{
        let (h, offset) = try parseHeader(data: data.subdata(in: 1..<data.count))
        header = h
        isProgressive = Bool(data[offset + 1])
        body = try parseBody(data: data.subdata(in: (offset + 2)..<data.count))
    }
    
    func  toData() throws -> Data {
        var res = try type.toData()
        let hData = try header.toData()
        let bData = try body.toData()
        let isPData = ByteBackpacker.pack(self.isProgressive)
        res.append(hData)
        res.append(Data(bytes: isPData))
        res.append(bData)
        return res
    }

    
}
