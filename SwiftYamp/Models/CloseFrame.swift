//
//  CloseFrame.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/13/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import Foundation
import ByteBackpacker

public struct CloseFrame: Equatable, YampFrame, YampTypedFrame{
    
    public var frameType:FrameType{
        return type.type
    }
    
    let type:BaseFrame = BaseFrame(type: FrameType.Close)
    let size:UInt16
    var reason:String = "" // (optional)
    
    public static func ==(lhs: CloseFrame, rhs: CloseFrame) -> Bool {
        return lhs.type == rhs.type && lhs.size == rhs.size && lhs.reason == rhs.reason
    }
    
    public init(size: UInt16) {
        self.size = size
    }
    
    public init(size: UInt16, reason: String?) {
        self.size = size
        self.reason = reason ?? ""
    }
    
    public init(data: Data) throws{
        let dataSize = data.count
        if dataSize < 3 { throw SerializationError.WrongDataFrameSize(dataSize) }
        size =  UInt16(bigEndian: data.subdata(in: 1..<3).withUnsafeBytes{$0.pointee})
        let offset:Int = 3 + Int(size)
        if dataSize != offset { throw SerializationError.WrongDataFrameSize(dataSize) }
        let s = data.subdata(in: 3..<offset)
        reason = String(data: s, encoding: String.Encoding.utf8) ?? ""
    }
    
    public func toData() throws -> Data{
        var r = ByteBackpacker.pack(self.type.type.rawValue)
        r = r + ByteBackpacker.pack(self.size, byteOrder: .bigEndian)
        guard let encStr = self.reason.data(using: .utf8) else{
            throw SerializationError.UnexpectedError
        }
        var res = Data(bytes: r)
        res.append(encStr)
        return res
    }
    
}
