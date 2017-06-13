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
    case TypeNotFound(UInt8)
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
        default:
            throw SerializationError.UnexpectedError
        }
    }
}

func deserialize(data: Data) throws -> YampFrame{
   
    if data.count < 1 { throw SerializationError.WrongDataFrameSize(data.count) }
    
    guard let type = FrameType(rawValue: data[0]) else {
        throw SerializationError.TypeNotFound(data[0])
    }
    
    let resultFrame = try DeserializeFrame.Frame(type, data).parse()
    return resultFrame
    
}
