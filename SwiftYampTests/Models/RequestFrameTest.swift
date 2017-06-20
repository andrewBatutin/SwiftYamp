//
//  RequestFrameTest.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/14/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import XCTest

class RequestFrameTest: XCTestCase {
    
    let requestType:UInt8 = 0x11
    
    func testRequestFrameDeSerializationSuccsefull() {
        let expectedHeaderData:[UInt8] = [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x41, 0x41, 0x41, 0x41]
        let expectedBodyData:[UInt8] = [0x00, 0x00, 0x00, 0x04, 0x01, 0x02, 0x03, 0x04]
        let fullData = Data([requestType] + expectedHeaderData + expectedBodyData)
        let subject = try! RequestFrame(data: fullData)
        let realData = try! subject.toData()
        XCTAssertEqual(realData, fullData)
        XCTAssertEqual(subject.type, BaseFrame(type: FrameType.Request))
        
        let expectedHeader = UserMessageHeaderFrame(uid: [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], size: 4, uri: "AAAA")
        let expectedBody = UserMessageBodyFrame(size: 4, body: [0x01, 0x02, 0x03, 0x04])
        XCTAssertEqual(expectedHeader, subject.header)
        XCTAssertEqual(expectedBody, subject.body)
    }
    
    func testRequestFrameSerializationSuccesfull() {
        let header = UserMessageHeaderFrame(uid: [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], size: 4, uri: "AAAA")
        let body = UserMessageBodyFrame(size: 4, body: [0x01, 0x02, 0x03, 0x04])
        let subject = RequestFrame(header: header, body: body)
        let expectedHeaderData:[UInt8] = [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x41, 0x41, 0x41, 0x41]
        let expectedBodyData:[UInt8] = [0x00, 0x00, 0x00, 0x04, 0x01, 0x02, 0x03, 0x04]
        let expectedData = Data([requestType] + expectedHeaderData + expectedBodyData)
        XCTAssertEqual(expectedData, try! subject.toData())
    }
    
}
