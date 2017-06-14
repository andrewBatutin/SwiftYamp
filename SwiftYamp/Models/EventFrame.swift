//
//  EventFrame.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/14/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import Foundation

struct EventFrame: Equatable, YampFrame {
    
    let type:BaseFrame = BaseFrame(type: FrameType.Event)
    let header:UserMessageHeaderFrame
    let body:UserMessageBodyFrame
    
   static func parseHeader(data: Data) throws -> (header: UserMessageHeaderFrame, offset: Int){
        let dataSize = data.count
        if dataSize < 17 { throw SerializationError.WrongDataFrameSize(dataSize) }
        let uid = Array(data.subdata(in: 0..<16))
        let size = data[16]
        let offset:Int = 17 + Int(size)
        if dataSize < offset { throw SerializationError.WrongDataFrameSize(dataSize) }
        let s = data.subdata(in: 17..<offset)
        guard let uri = String(data: s, encoding: String.Encoding.utf8) else {
            throw SerializationError.UnexpectedError
        }
        let header = UserMessageHeaderFrame(uid: uid, size: size, uri: uri)
        return (header, offset)
    }
    
    static func parseBody(data: Data) throws -> UserMessageBodyFrame{
        let dataSize = data.count
        if dataSize < 5 { throw SerializationError.WrongDataFrameSize(dataSize) }
        let size:UInt32 = data.subdata(in: 0..<4).withUnsafeBytes{$0.pointee}
        var body:[UInt8]? = nil
        if size > 0{
            let offset:Int = 4 + Int(size)
            if dataSize < offset { throw SerializationError.WrongDataFrameSize(dataSize) }
            body = Array(data.subdata(in: 4..<offset))
        }
        return UserMessageBodyFrame(size: size, body: body)
    }
    
    static func ==(lhs: EventFrame, rhs: EventFrame) -> Bool {
        return lhs.type == rhs.type && lhs.header == rhs.header && lhs.body == rhs.body
    }
    
    init(header: UserMessageHeaderFrame, body: UserMessageBodyFrame) {
        self.header = header
        self.body = body
    }
    
    init(data: Data) throws{
        let (h, offset) = try EventFrame.parseHeader(data: data.subdata(in: 1..<data.count))
        header = h
        body = try EventFrame.parseBody(data: data.subdata(in: (offset + 1)..<data.count))
    }

    func  toData() throws -> Data {
        var res = try type.toData()
        let hData = try header.toData()
        let bData = try body.toData()
        res.append(hData)
        res.append(bData)
        return res
    }
    
}
