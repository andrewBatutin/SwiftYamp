//
//  CancelFrame.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/14/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import Foundation
import ByteBackpacker

public struct CancelFrame: Equatable, YampFrame, YampTypedFrame{
    
    public var frameType:FrameType{
        return type.type
    }
    
    let type:BaseFrame = BaseFrame(type: FrameType.Cancel)
    let header:UserMessageHeaderFrame
    let requestUid:[UInt8]
    let kill:Bool
    
    public static func ==(lhs: CancelFrame, rhs: CancelFrame) -> Bool {
        return lhs.type == rhs.type && lhs.header == rhs.header && lhs.requestUid == rhs.requestUid && lhs.kill == rhs.kill
    }
    
    public init(header: UserMessageHeaderFrame, requestUid: [UInt8], kill: Bool) {
        self.header = header
        self.requestUid = requestUid
        self.kill = kill
    }
    
    public init(data: Data) throws{
        let (h, offset) = try parseHeader(data: data.subdata(in: 1..<data.count))
        header = h
        if offset + 16 >= data.count { throw SerializationError.WrongDataFrameSize(data.count) }
        requestUid = Array(data.subdata(in: offset..<(offset + 16)))
        if offset + 16 >= data.count { throw SerializationError.WrongDataFrameSize(data.count) }
        kill = Bool(data[offset + 16])
    }
    
    public func toData() throws -> Data {
        var res = try type.toData()
        let hData = try header.toData()
        let killData = ByteBackpacker.pack(self.kill)
        res.append(hData)
        res.append(Data(bytes: self.requestUid))
        res.append(Data(bytes: killData))
        return res
    }

}
