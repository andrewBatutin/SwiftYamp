//
//  HandshakeFrame.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/13/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import Foundation
import ByteBackpacker

public struct HandshakeFrame: Equatable, YampFrame, YampTypedFrame {
    
    public var frameType:FrameType{
        return type.type
    }
    
    let type:BaseFrame = BaseFrame(type: FrameType.Handshake)
    let version:UInt16
    
    public static func ==(lhs: HandshakeFrame, rhs: HandshakeFrame) -> Bool {
        return lhs.type == rhs.type && lhs.version == rhs.version
    }
    
    public init(version: UInt16) {
        self.version = version
    }
    
   public init(data: Data) throws{
        let dataSize = data.count
        if dataSize < 3 { throw SerializationError.WrongDataFrameSize(dataSize) }
        version = UInt16(bigEndian: data.subdata(in: 1..<3).withUnsafeBytes{$0.pointee})
    }
    
    public func toData() throws -> Data{
        var r = ByteBackpacker.pack(self.type.type.rawValue)
        r = r + ByteBackpacker.pack(self.version, byteOrder: .bigEndian)
        let res = Data(bytes: r)
        return res
    }
    
}
