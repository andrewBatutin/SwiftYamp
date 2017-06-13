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
    
}

enum SerfializeFrame {
    case Frame(FrameType, [Int8])
    
    func parse() -> YampFrame{
        switch self {
        case .Frame(.Handshake, let x):
            print("")
            return BaseFrame(type: .Cancel)
        default:
            print("")
            return BaseFrame(type: .Cancel)
        }
    }
}

func serialize(data: Data) throws -> BaseFrame{
   
    if data.count < 1 { throw SerializationError.UnexpectedError }
    
    guard let type = FrameType(rawValue: data[0]) else {
        throw SerializationError.TypeNotFound(data[0])
    }
    return BaseFrame(type: type)
    
}

func serializeT<T: YampFrame>(data: Data) throws -> T{
    
    guard let type = FrameType(rawValue: data[0]) else {
        throw SerializationError.TypeNotFound(data[0])
    }
    return BaseFrame(type: type) as! T
    
}
