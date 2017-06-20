//
//  PingFrame.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/13/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import Foundation
import ByteBackpacker

public struct PingFrame: Equatable, YampFrame, YampTypedFrame{
    
    private let ackIndex = 0x01
    private let sizeIndex = 0x02
    private let payloadIndex = 0x03
    
    public var frameType:FrameType{
        return type.type
    }
    
    let type:BaseFrame = BaseFrame(type: FrameType.Ping)
    let ack:Bool
    let size:UInt8
    var payload:String = "" // (optional)
    
    public static func ==(lhs: PingFrame, rhs: PingFrame) -> Bool {
        return lhs.type == rhs.type && lhs.ack == rhs.ack && lhs.size == rhs.size && lhs.payload == rhs.payload
    }
    
    public init(ack:Bool, size: UInt8) {
        self.ack = ack
        self.size = size
    }
    
    public init(ack:Bool, size: UInt8, payload: String?) {
        self.ack = ack
        self.size = size
        self.payload = payload ?? ""
    }
    
    public init(data: Data) throws{
        let dataSize = data.count
        if dataSize < sizeIndex { throw SerializationError.WrongDataFrameSize(dataSize) }
        ack = Bool(data[ackIndex])
        size = data[sizeIndex]
        let offset:Int = payloadIndex + Int(size)
        if dataSize != offset { throw SerializationError.WrongDataFrameSize(dataSize) }
        let s = data.subdata(in: payloadIndex..<offset)
        payload = String(data: s, encoding: String.Encoding.utf8) ?? ""
    }
    
    public func toData() throws -> Data{
        var r = ByteBackpacker.pack(self.type.type.rawValue)
        r = r + ByteBackpacker.pack(self.ack)
        r = r + ByteBackpacker.pack(self.size)
        guard let encStr = self.payload.data(using: .utf8) else{
            throw SerializationError.UnexpectedError
        }
        var res = Data(bytes: r)
        res.append(encStr)
        return res
    }
}
