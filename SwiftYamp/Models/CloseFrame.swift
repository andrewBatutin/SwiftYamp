//
//  CloseFrame.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/13/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import Foundation
import ByteBackpacker

struct CloseFrame: Equatable, YampFrame {
    
    let type:BaseFrame = BaseFrame(type: FrameType.Close)
    let size:UInt16
    var reason:String = "" // (optional)
    
    static func ==(lhs: CloseFrame, rhs: CloseFrame) -> Bool {
        return lhs.type == rhs.type && lhs.size == rhs.size && lhs.reason == rhs.reason
    }
    
    init(size: UInt16) {
        self.size = size
    }
    
    init(size: UInt16, reason: String?) {
        self.size = size
        self.reason = reason ?? ""
    }
    
    init(data: Data) throws{
        let dataSize = data.count
        if dataSize < 3 { throw SerializationError.WrongDataFrameSize(dataSize) }
        size = data.subdata(in: 1..<3).withUnsafeBytes{$0.pointee}
        let offset:Int = 3 + Int(size)
        if dataSize != offset { throw SerializationError.WrongDataFrameSize(dataSize) }
        let s = data.subdata(in: 3..<offset)
        reason = String(data: s, encoding: String.Encoding.utf8) ?? ""
    }
    
    func toData() throws -> Data{
        var r = ByteBackpacker.pack(self.type.type.rawValue)
        r = r + ByteBackpacker.pack(self.size)
        guard let encStr = self.reason.data(using: .utf8) else{
            throw SerializationError.UnexpectedError
        }
        var res = Data(bytes: r)
        res.append(encStr)
        return res
    }
    
}
