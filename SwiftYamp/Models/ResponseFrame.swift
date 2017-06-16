//
//  ResponseFrame.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/14/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import Foundation
import ByteBackpacker

public struct ResponseFrame: Equatable, YampFrame {
    
    let type:BaseFrame = BaseFrame(type: FrameType.Response)
    let header:UserMessageHeaderFrame
    let requestUid:[UInt8]
    let responseType:ResponseType
    let body:UserMessageBodyFrame
    
    public static func ==(lhs: ResponseFrame, rhs: ResponseFrame) -> Bool {
        return lhs.type == rhs.type && lhs.header == rhs.header && lhs.requestUid == rhs.requestUid && lhs.responseType == rhs.responseType && lhs.body == rhs.body
    }
    
    public init(header: UserMessageHeaderFrame, requestUid: [UInt8], responseType: ResponseType, body: UserMessageBodyFrame) {
        self.header = header
        self.requestUid = requestUid
        self.responseType = responseType
        self.body = body
    }
    
    
    public init(data: Data) throws{
        let (h, offset) = try parseHeader(data: data.subdata(in: 1..<data.count))
        header = h
        if offset + 16 >= data.count { throw SerializationError.WrongDataFrameSize(data.count) }
        requestUid = Array(data.subdata(in: offset..<(offset + 16)))
        if offset + 16 >= data.count { throw SerializationError.WrongDataFrameSize(data.count) }
        guard let rType = ResponseType(rawValue: data[offset + 16 ]) else {
            throw SerializationError.ReponseTypeNotFound(data[offset + 16 ])
        }
        responseType = rType
        if offset + 17 >= data.count { throw SerializationError.WrongDataFrameSize(data.count) }
        body = try parseBody(data: data.subdata(in: (offset + 17)..<data.count))
    }
    
    public func toData() throws -> Data {
        var res = try type.toData()
        let hData = try header.toData()
        let respTypeData = ByteBackpacker.pack(responseType.rawValue)
        let bData = try body.toData()
        res.append(hData)
        res.append(Data(bytes: self.requestUid))
        res.append(Data(bytes: respTypeData))
        res.append(bData)
        return res
    }
    
}
