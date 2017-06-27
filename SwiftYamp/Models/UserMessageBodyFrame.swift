//
//  UserMessageBodyFrame.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/13/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import Foundation
import ByteBackpacker

public struct UserMessageBodyFrame: Equatable, YampFrame {
    
    public let size:UInt32
    public private(set) var body:[UInt8]? // (optional) maximum 4Gb
    
    public static func ==(lhs: UserMessageBodyFrame, rhs: UserMessageBodyFrame) -> Bool {
        let lBody = lhs.body ?? []
        let rBody = rhs.body ?? []
        return lhs.size == rhs.size && lBody == rBody
    }
    
    public init(size: UInt32, body: [UInt8]?) {
        self.size = size
        self.body = body ?? []
    }
    
    public init(data: Data) throws {
        let dataSize = data.count
        if dataSize < 5 { throw SerializationError.WrongDataFrameSize(dataSize) }
        size = UInt32(bigEndian: data.subdata(in: 0..<4).withUnsafeBytes{$0.pointee})
        if size > 0{
            let offset:Int = 4 + Int(size)
            if dataSize != offset { throw SerializationError.WrongDataFrameSize(dataSize) }
            body = Array(data.subdata(in: 4..<offset))
        }
    }
    
    public func  toData() throws -> Data {
        var r = ByteBackpacker.pack(self.size, byteOrder: .bigEndian)
        if let b = body {
            r += b
        }
        let res = Data(bytes: r)
        return res
    }
    
}
