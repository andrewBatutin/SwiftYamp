//
//  EventFrameTest.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/14/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import XCTest

class EventFrameTest: XCTestCase {
    
    let eventType:UInt8 = 0x10
    
    func testEventFrameDeSerializationSuccsefull() {
        let expectedHeaderData:[UInt8] = [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x41, 0x41, 0x41, 0x41]
        let expectedBodyData:[UInt8] = [0x00, 0x00, 0x00, 0x04, 0x01, 0x02, 0x03, 0x04]
        let fullData = Data([eventType] + expectedHeaderData + expectedBodyData)
        let subject = try! EventFrame(data: fullData)
        let realData = try! subject.toData()
        XCTAssertEqual(realData, fullData)
        XCTAssertEqual(subject.type, BaseFrame(type: FrameType.Event))
        
        let expectedHeader = UserMessageHeaderFrame(uid: [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], size: 4, uri: "AAAA")
        let expectedBody = UserMessageBodyFrame(size: 4, body: [0x01, 0x02, 0x03, 0x04])
        XCTAssertEqual(expectedHeader, subject.header)
        XCTAssertEqual(expectedBody, subject.body)
    }
    
    func testEventFrameDeSerializationThrowsWithShortHeaderUidData() {
        let inputData = Data(bytes: [eventType, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x41, 0x41, 0x41, 0x41])
        XCTAssertThrowsError(try EventFrame(data: inputData))
    }
    
    func testEventFrameDeSerializationThrowsWithShortHeaderUriData() {
        let inputData = Data(bytes: [eventType, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x41, 0x41, 0x41])
        XCTAssertThrowsError(try EventFrame(data: inputData))
    }
    
    func testEventFrameDeSerializationThrowsWithShortBodyData() {
        let expectedHeaderData:[UInt8] = [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x41, 0x41, 0x41, 0x41]
        let expectedBodyData:[UInt8] = [0x04, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03]
        let fullData = Data([eventType] + expectedHeaderData + expectedBodyData)
        XCTAssertThrowsError(try EventFrame(data: fullData))
    }
    
    func testEventFrameSerializationSuccesfull() {
        let header = UserMessageHeaderFrame(uid: [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], size: 4, uri: "AAAA")
        let body = UserMessageBodyFrame(size: 4, body: [0x01, 0x02, 0x03, 0x04])
        let subject = EventFrame(header: header, body: body)
        let expectedHeaderData:[UInt8] = [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x41, 0x41, 0x41, 0x41]
        let expectedBodyData:[UInt8] = [0x00, 0x00, 0x00, 0x04, 0x01, 0x02, 0x03, 0x04]
        let expectedData = Data([eventType] + expectedHeaderData + expectedBodyData)
        XCTAssertEqual(expectedData, try! subject.toData())
    }
    
}
