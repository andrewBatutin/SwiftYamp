//
//  CloseFrame.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/13/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import Foundation
import ByteBackpacker

public enum CloseCodeType: UInt8{
    case Unknown = 0x00
    case VersionNotSupported = 0x01
    case Timeout = 0x02
    case Redirect = 0x03
}

public struct CloseFrame: Equatable, YampFrame, YampTypedFrame{
    
    private let typeIndex = 0x00
    private let closeCodeIndex = 0x01
    private let sizeIndex = 0x02
    private let messageIndex = 0x04
    
    public var frameType:FrameType{
        return type.type
    }
    
    let type:BaseFrame = BaseFrame(type: FrameType.Close)
    let closeCode:CloseCodeType
    let size:UInt16
    var message:String = "" // (optional)
    
    public static func ==(lhs: CloseFrame, rhs: CloseFrame) -> Bool {
        return lhs.type == rhs.type && lhs.closeCode == rhs.closeCode && lhs.size == rhs.size && lhs.message == rhs.message
    }
    
    public init(closeCode: CloseCodeType) {
        self.closeCode = closeCode
        self.size = 0
    }
    
    public init(closeCode: CloseCodeType, message: String?) {
        self.closeCode = closeCode
        self.size = UInt16(message?.characters.count ?? 0)
        self.message = message ?? ""
    }
    
    public init(data: Data) throws{
        let dataSize = data.count
        if dataSize < messageIndex { throw SerializationError.WrongDataFrameSize(dataSize) }
        guard let cCode = CloseCodeType(rawValue: data[closeCodeIndex]) else {
            throw SerializationError.CloseCodeTypeNotFound(data[closeCodeIndex])
        }
        closeCode = cCode
        size =  UInt16(bigEndian: data.subdata(in: sizeIndex..<messageIndex).withUnsafeBytes{$0.pointee})
        let offset:Int = messageIndex + Int(size)
        if dataSize != offset { throw SerializationError.WrongDataFrameSize(dataSize) }
        let s = data.subdata(in: messageIndex..<offset)
        message = String(data: s, encoding: String.Encoding.utf8) ?? ""
    }
    
    public func toData() throws -> Data{
        var r = ByteBackpacker.pack(self.type.type.rawValue)
        r = r + ByteBackpacker.pack(self.closeCode.rawValue)
        r = r + ByteBackpacker.pack(self.size, byteOrder: .bigEndian)
        guard let encStr = self.message.data(using: .utf8) else{
            throw SerializationError.UnexpectedError
        }
        var res = Data(bytes: r)
        res.append(encStr)
        return res
    }
    
}
