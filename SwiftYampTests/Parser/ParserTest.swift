//
//  ParserTest.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/13/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import XCTest

class ParserTest: XCTestCase {
    
    func testPingFrameDeSerializationSuccsesfyll() {
        let inputData = Data(bytes: [0x01, 0x04, 0x41, 0x41, 0x41, 0x41])
        let expectedFrame = PingFrame(size: 4, payload: "AAAA")
        let realFrame = try! deserialize(data: inputData) as! PingFrame
        XCTAssertEqual(realFrame, expectedFrame)
    }
    
    func testPingFrameDeSerializationWithInvalidDataThorwsError() {
        let inputData = Data(bytes: [0x99, 0x04, 0x41, 0x41, 0x41, 0x41])
        XCTAssertThrowsError( try deserialize(data: inputData) )
    }
    
    func testResponseFrameDeSerializationSuccsesfyll() {
        let expectedHeaderData:[UInt8] = [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x41, 0x41, 0x41, 0x41]
        let expectedUID:[UInt8] = [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x09]
        let expectedBodyData:[UInt8] = [0x04, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03, 0x04]
        let expectedHeader = UserMessageHeaderFrame(uid: [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], size: 4, uri: "AAAA")
        let expectedBody = UserMessageBodyFrame(size: 4, body: [0x01, 0x02, 0x03, 0x04])
        let expectedFrame = ResponseFrame(header: expectedHeader, requestUid: expectedUID, responseType: ResponseType.Cancelled, body: expectedBody)
        let fullData = Data([0x08] + expectedHeaderData + expectedUID + [0x03] + expectedBodyData)
        let realFrame = try! deserialize(data: fullData) as! ResponseFrame
        XCTAssertEqual(realFrame, expectedFrame)
    }
    
}
