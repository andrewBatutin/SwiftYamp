//
//  ResponseFrameTest.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/14/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import XCTest

class ResponseFrameTest: XCTestCase {
    
    func testEventFrameDeSerializationSuccsefull() {
        let expectedHeaderData:[UInt8] = [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x41, 0x41, 0x41, 0x41]
        let expectedUID:[UInt8] = [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x09]
        let expectedBodyData:[UInt8] = [0x04, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03, 0x04]
        let fullData = Data([0x08] + expectedHeaderData + expectedUID + [0x03] + expectedBodyData)
        let subject = try! ResponseFrame(data: fullData)
        let realData = try! subject.toData()
        XCTAssertEqual(realData, fullData)
        XCTAssertEqual(subject.type, BaseFrame(type: FrameType.Response))
        
        let expectedHeader = UserMessageHeaderFrame(uid: [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], size: 4, uri: "AAAA")
        let expectedBody = UserMessageBodyFrame(size: 4, body: [0x01, 0x02, 0x03, 0x04])
        let expectedResponseType = ResponseType.Cancelled
        XCTAssertEqual(expectedHeader, subject.header)
        XCTAssertEqual(expectedBody, subject.body)
        XCTAssertEqual(expectedResponseType, subject.responseType)
    }
    
    func testResponseFrameDeSerializationThrowsWithShortHeaderUidData() {
        let inputData = Data(bytes: [0x08, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x41, 0x41, 0x41, 0x41])
        XCTAssertThrowsError(try ResponseFrame(data: inputData))
    }
    
    func testResponseFrameDeSerializationThrowsWithShortHeaderUriData() {
        let inputData = Data(bytes: [0x05, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x41, 0x41, 0x41])
        XCTAssertThrowsError(try ResponseFrame(data: inputData))
    }
    
    func testResponseFrameDeSerializationThrowsWithShortBodyData() {
        let expectedHeaderData:[UInt8] = [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x41, 0x41, 0x41, 0x41]
        let expectedBodyData:[UInt8] = [0x04, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03]
        let expectedUID:[UInt8] = [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x09]
        let fullData = Data([0x08] + expectedHeaderData + expectedUID + [0x03] + expectedBodyData)
        XCTAssertThrowsError(try ResponseFrame(data: fullData))
    }
    
    func testResponseFrameDeSerializationThrowsWithoutResponseType() {
        let expectedHeaderData:[UInt8] = [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x41, 0x41, 0x41, 0x41]
        let expectedBodyData:[UInt8] = [0x04, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03]
        let expectedUID:[UInt8] = [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x09]
        let fullData = Data([0x08] + expectedHeaderData + expectedUID + expectedBodyData)
        XCTAssertThrowsError(try ResponseFrame(data: fullData))
    }
    
}