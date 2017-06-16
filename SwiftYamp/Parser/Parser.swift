//
//  Deserializer.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/12/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import Foundation

enum SerializationError: Error{
    
    case UnexpectedError
    case FrameTypeNotFound(UInt8)
    case ReponseTypeNotFound(UInt8)
    case WrongDataFrameSize(Int)
    
}

enum DeserializeFrame {
    case Frame(FrameType, Data)
    
    func parse() throws -> YampFrame{
        switch self {
        case .Frame(.Handshake, let data):
            return try HandshakeFrame(data: data)
        case .Frame(.Ping, let data):
            return try PingFrame(data: data)
        case .Frame(.Pong, let data):
            return try PongFrame(data: data)
        case .Frame(.Close, let data):
            return try CloseFrame(data: data)
        case .Frame(.Close_Redirect, let data):
            return try CloseRedirectFrame(data: data)
        case .Frame(.Event, let data):
            return try EventFrame(data: data)
        case .Frame(.Request, let data):
            return try RequestFrame(data: data)
        case .Frame(.Cancel, let data):
            return try CancelFrame(data: data)
        case .Frame(.Response, let data):
            return try ResponseFrame(data: data)
        default:
            throw SerializationError.UnexpectedError
        }
    }
}

public func deserialize(data: Data) throws -> YampFrame{
   
    if data.count < 1 { throw SerializationError.WrongDataFrameSize(data.count) }
    
    guard let type = FrameType(rawValue: data[0]) else {
        throw SerializationError.FrameTypeNotFound(data[0])
    }
    
    let resultFrame = try DeserializeFrame.Frame(type, data).parse()
    return resultFrame
}

func parseHeader(data: Data) throws -> (header: UserMessageHeaderFrame, offset: Int){
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
    return (header, offset + 1)
}

func parseBody(data: Data) throws -> UserMessageBodyFrame{
    let dataSize = data.count
    if dataSize < 5 { throw SerializationError.WrongDataFrameSize(dataSize) }
    let size:UInt32 = UInt32(bigEndian: data.subdata(in: 0..<4).withUnsafeBytes{$0.pointee})
    var body:[UInt8]? = nil
    if size > 0{
        let offset:Int = 4 + Int(size)
        if dataSize < offset { throw SerializationError.WrongDataFrameSize(dataSize) }
        body = Array(data.subdata(in: 4..<offset))
    }
    return UserMessageBodyFrame(size: size, body: body)
}
