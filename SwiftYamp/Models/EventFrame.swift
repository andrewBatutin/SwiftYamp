//
//  EventFrame.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/14/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import Foundation

struct EventFrame: Equatable, YampFrame {
    
    let type:BaseFrame = BaseFrame(type: FrameType.Event)
    let header:UserMessageHeaderFrame
    let body:UserMessageBodyFrame
    
    static func ==(lhs: EventFrame, rhs: EventFrame) -> Bool {
        return lhs.type == rhs.type && lhs.header == rhs.header && lhs.body == rhs.body
    }
    
    init(header: UserMessageHeaderFrame, body: UserMessageBodyFrame) {
        self.header = header
        self.body = body
    }
    
    init(data: Data) throws{
        let (h, offset) = try parseHeader(data: data.subdata(in: 1..<data.count))
        header = h
        body = try parseBody(data: data.subdata(in: (offset + 1)..<data.count))
    }

    func  toData() throws -> Data {
        var res = try type.toData()
        let hData = try header.toData()
        let bData = try body.toData()
        res.append(hData)
        res.append(bData)
        return res
    }
    
}
