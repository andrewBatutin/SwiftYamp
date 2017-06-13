//
//  PingFrame.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/13/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import Foundation
import ByteBackpacker

struct PingFrame: Equatable, YampFrame {
    
    let type:BaseFrame = BaseFrame(type: FrameType.Ping)
    let size:UInt8
    var payload:String = "" // (optional)
    
    static func ==(lhs: PingFrame, rhs: PingFrame) -> Bool {
        return lhs.type == rhs.type && lhs.size == rhs.size && lhs.payload == rhs.payload
    }
    
    init(size: UInt8) {
        self.size = size
    }
    
    init(size: UInt8, payload: String?) {
        self.size = size
        self.payload = payload ?? ""
    }
    
    init(data: Data) throws{
        let dataSize = data.count
        if dataSize < 1 { throw SerializationError.WrongDataFrameSize(dataSize) }
        size = data[1]
        let offset:Int = 2 + Int(size)
        if dataSize != offset { throw SerializationError.WrongDataFrameSize(dataSize) }
        let s = data.subdata(in: 2..<offset)
        payload = String(data: s, encoding: String.Encoding.utf8) ?? ""
    }
    
    func toData() throws -> Data{
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
