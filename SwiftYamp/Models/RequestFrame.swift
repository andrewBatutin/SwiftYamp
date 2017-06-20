//
//  RequestFrame.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/14/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import Foundation
import ByteBackpacker

public struct RequestFrame: Equatable, YampFrame, YampTypedFrame{
    
    public var frameType:FrameType{
        return type.type
    }
    
    let type:BaseFrame = BaseFrame(type: FrameType.Request)
    let header:UserMessageHeaderFrame
    let isProgressive:Bool
    let body:UserMessageBodyFrame
    
    public static func ==(lhs: RequestFrame, rhs: RequestFrame) -> Bool {
        return lhs.type == rhs.type && lhs.header == rhs.header && lhs.isProgressive == rhs.isProgressive && lhs.body == rhs.body
    }
    
    public init(header: UserMessageHeaderFrame, isProgressive: Bool, body: UserMessageBodyFrame) {
        self.header = header
        self.isProgressive = isProgressive
        self.body = body
    }
    
    public init(data: Data) throws{
        let (h, offset) = try parseHeader(data: data.subdata(in: 1..<data.count))
        header = h
        if offset >= data.count { throw SerializationError.WrongDataFrameSize(data.count) }
        isProgressive = Bool(data[offset])
        if offset + 1 >= data.count { throw SerializationError.WrongDataFrameSize(data.count) }
        body = try parseBody(data: data.subdata(in: (offset + 1)..<data.count))
    }
    
    public func  toData() throws -> Data {
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
