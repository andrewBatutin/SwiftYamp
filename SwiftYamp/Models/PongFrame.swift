//
//  PongFrame.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/13/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import Foundation
import ByteBackpacker

public struct PongFrame: Equatable, YampFrame, YampTypedFrame{
    
    public var frameType:FrameType{
        return type.type
    }
    
    let type:BaseFrame = BaseFrame(type: FrameType.Pong)
    let size:UInt8
    var payload:String = "" // (optional)
    
    public static func ==(lhs: PongFrame, rhs: PongFrame) -> Bool {
        return lhs.type == rhs.type && lhs.size == rhs.size && lhs.payload == rhs.payload
    }
    
    public init(size: UInt8) {
        self.size = size
    }
    
    public init(size: UInt8, payload: String?) {
        self.size = size
        self.payload = payload ?? ""
    }
    
    public init(data: Data) throws{
        let dataSize = data.count
        if dataSize < 1 { throw SerializationError.WrongDataFrameSize(dataSize) }
        size = data[1]
        let offset:Int = 2 + Int(size)
        if dataSize != offset { throw SerializationError.WrongDataFrameSize(dataSize) }
        let s = data.subdata(in: 2..<offset)
        payload = String(data: s, encoding: String.Encoding.utf8) ?? ""
    }
    
    public func toData() throws -> Data{
        var r = ByteBackpacker.pack(self.type.type.rawValue)
        r = r + ByteBackpacker.pack(self.size)
        guard let encStr = self.payload.data(using: .utf8) else{
            throw SerializationError.UnexpectedError
        }
        var res = Data(bytes: r)
        res.append(encStr)
        return res
    }
}
