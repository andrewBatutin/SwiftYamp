//
//  RequestFrameTest.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/14/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import XCTest

class RequestFrameTest: XCTestCase {
    
    func testRequestFrameDeSerializationSuccsefullNotProgressive() {
        let expectedHeaderData:[UInt8] = [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x41, 0x41, 0x41, 0x41]
        let expectedBodyData:[UInt8] = [0x04, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03, 0x04]
        let fullData = Data([0x06] + expectedHeaderData + [0x00] + expectedBodyData)
        let subject = try! RequestFrame(data: fullData)
        let realData = try! subject.toData()
        XCTAssertEqual(realData, fullData)
        XCTAssertEqual(subject.type, BaseFrame(type: FrameType.Request))
        
        let expectedHeader = UserMessageHeaderFrame(uid: [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], size: 4, uri: "AAAA")
        let expectedBody = UserMessageBodyFrame(size: 4, body: [0x01, 0x02, 0x03, 0x04])
        let expectedProgressive = false
        XCTAssertEqual(expectedHeader, subject.header)
        XCTAssertEqual(expectedBody, subject.body)
        XCTAssertEqual(expectedProgressive, subject.isProgressive)
    }
    
    func testRequestFrameDeSerializationSuccsefullIsProgressive() {
        let expectedHeaderData:[UInt8] = [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x41, 0x41, 0x41, 0x41]
        let expectedBodyData:[UInt8] = [0x04, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03, 0x04]
        let fullData = Data([0x06] + expectedHeaderData + [0x01] + expectedBodyData)
        let subject = try! RequestFrame(data: fullData)
        let realData = try! subject.toData()
        XCTAssertEqual(realData, fullData)
        XCTAssertEqual(subject.type, BaseFrame(type: FrameType.Request))
        
        let expectedHeader = UserMessageHeaderFrame(uid: [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], size: 4, uri: "AAAA")
        let expectedBody = UserMessageBodyFrame(size: 4, body: [0x01, 0x02, 0x03, 0x04])
        let expectedProgressive = true
        XCTAssertEqual(expectedHeader, subject.header)
        XCTAssertEqual(expectedBody, subject.body)
        XCTAssertEqual(expectedProgressive, subject.isProgressive)
    }
    
    func testRequestFrameSerializationSuccesfull() {
        let header = UserMessageHeaderFrame(uid: [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], size: 4, uri: "AAAA")
        let body = UserMessageBodyFrame(size: 4, body: [0x01, 0x02, 0x03, 0x04])
        let subject = RequestFrame(header: header, isProgressive: true, body: body)
        let expectedHeaderData:[UInt8] = [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x41, 0x41, 0x41, 0x41]
        let expectedBodyData:[UInt8] = [0x04, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03, 0x04]
        let expectedData = Data([0x06] + expectedHeaderData + [0x01] + expectedBodyData)
        XCTAssertEqual(expectedData, try! subject.toData())
    }
    
}
