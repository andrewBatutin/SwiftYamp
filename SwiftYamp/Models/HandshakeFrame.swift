//
//  HandshakeFrame.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/13/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import Foundation
import ByteBackpacker

public struct HandshakeFrame: Equatable, YampFrame {
    
    let type:BaseFrame = BaseFrame(type: FrameType.Handshake)
    let version:UInt16
    let size:UInt8
    let serializer:String
    
    public static func ==(lhs: HandshakeFrame, rhs: HandshakeFrame) -> Bool {
        return lhs.type == rhs.type && lhs.version == rhs.version && lhs.size == rhs.size && lhs.serializer == rhs.serializer
    }
    
    public init(version: UInt16, size: UInt8, serializer:String) {
        self.version = version
        self.size = size
        self.serializer = serializer
    }
    
   public init(data: Data) throws{
        let dataSize = data.count
        if dataSize < 3 { throw SerializationError.WrongDataFrameSize(dataSize) }
    version = UInt16(bigEndian: data.subdata(in: 1..<3).withUnsafeBytes{$0.pointee})
        size = data[3]
        let offset:Int = 4 + Int(size)
        if dataSize != offset { throw SerializationError.WrongDataFrameSize(dataSize) }
        let s = data.subdata(in: 4..<offset)
        guard let str = String(data: s, encoding: String.Encoding.utf8) else {
            throw SerializationError.UnexpectedError
        }
        serializer = str
    }
    
    public func toData() throws -> Data{
        
        var r = ByteBackpacker.pack(self.type.type.rawValue)
        var v = self.version
        let vData = NSData(bytes: &v, length: MemoryLayout<Int16>.size)
        r = r + ByteBackpacker.pack(self.version)
        r = r + ByteBackpacker.pack(self.size)
        guard let encStr = self.serializer.data(using: .utf8) else{
            throw SerializationError.UnexpectedError
        }
        var res = Data(bytes: r)
        res.append(encStr)
        return res
    }
    
}
