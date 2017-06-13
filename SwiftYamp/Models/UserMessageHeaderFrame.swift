//
//  UserMessageHeaderFrame.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/13/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import Foundation
import ByteBackpacker

struct UserMessageHeaderFrame: Equatable, YampFrame {
    
    let uid:[UInt8]
    let size:UInt8
    let uri:String
    
    static func ==(lhs: UserMessageHeaderFrame, rhs: UserMessageHeaderFrame) -> Bool {
        return lhs.uid == rhs.uid && lhs.size == rhs.size && lhs.uri == rhs.uri
    }
    
    init(uid: [UInt8], size: UInt8, uri: String) {
        self.uid = uid
        self.size = size
        self.uri = uri
    }
    
    init(data: Data) throws {
        let dataSize = data.count
        if dataSize < 17 { throw SerializationError.WrongDataFrameSize(dataSize) }
        
        uid = Array(data.subdata(in: 0..<16))
        size = data[16]
        let offset:Int = 17 + Int(size)
        if dataSize != offset { throw SerializationError.WrongDataFrameSize(dataSize) }
        let s = data.subdata(in: 17..<offset)
        guard let str = String(data: s, encoding: String.Encoding.utf8) else {
            throw SerializationError.UnexpectedError
        }
        uri = str
        
    }
    
    func  toData() throws -> Data {
        var r = self.uid
        r = r + ByteBackpacker.pack(self.size)
        guard let encStr = self.uri.data(using: .utf8) else{
            throw SerializationError.UnexpectedError
        }
        var res = Data(bytes: r)
        res.append(encStr)
        return res
    }
}
