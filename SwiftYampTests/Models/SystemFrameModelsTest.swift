//
//  BaseFrameTest.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/12/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import XCTest
@testable import SwiftYamp

class SystemFrameModelsTest: XCTestCase {
    
    func testFrameTypeIsSetCorrectly() {
        let subject = BaseFrame(type: FrameType.Handshake)
        XCTAssertEqual(subject.type, FrameType.Handshake)
    }
    
    func testHandshakeFrameIsCreatedCorrectly() {
        let subject = HandshakeFrame(version: 0x01, size: 0x04, serializer: "1234")
        let expectedType = BaseFrame(type: FrameType.Handshake)
        XCTAssertEqual(subject.type, expectedType)
        XCTAssertEqual(subject.version, 0x01)
        XCTAssertEqual(subject.size, 0x04)
        XCTAssertEqual(subject.serializer, "1234")
    }
    
    func testPingFrameCreatedCorrectly() {
        let expectedType = BaseFrame(type: FrameType.Ping)
        let subject = PingFrame(size: 0x02, payload: "ping")
        XCTAssertEqual(subject.type, expectedType)
        XCTAssertEqual(subject.size, 0x02)
        XCTAssertEqual(subject.payload, "ping")
    }
    
    func testPingNoPayloadFrameCreatedCorrectly() {
        let expectedType = BaseFrame(type: FrameType.Ping)
        let subject = PingFrame(size: 0x02)
        XCTAssertEqual(subject.type, expectedType)
        XCTAssertEqual(subject.size, 0x02)
        XCTAssertEqual(subject.payload, "")
    }
    
    func testPongFrameCreatedCorrectly() {
        let expectedType = BaseFrame(type: FrameType.Pong)
        let subject = PongFrame(size: 0x02, payload: "pong")
        XCTAssertEqual(subject.type, expectedType)
        XCTAssertEqual(subject.size, 0x02)
        XCTAssertEqual(subject.payload, "pong")
    }
    
    func testPongNoPayloadFrameCreatedCorrectly() {
        let expectedType = BaseFrame(type: FrameType.Pong)
        let subject = PongFrame(size: 0x02)
        XCTAssertEqual(subject.type, expectedType)
        XCTAssertEqual(subject.size, 0x02)
        XCTAssertEqual(subject.payload, "")
    }
    
    func testCloseFrameCreatedCorrectly() {
        let expectedType = BaseFrame(type: FrameType.Close)
        let subject = CloseFrame(size: 0x02, reason: "Close")
        XCTAssertEqual(subject.type, expectedType)
        XCTAssertEqual(subject.size, 0x02)
        XCTAssertEqual(subject.reason, "Close")
    }
    
    func testCloseNoReasonFrameCreatedCorrectly() {
        let expectedType = BaseFrame(type: FrameType.Close)
        let subject = CloseFrame(size: 0x02)
        XCTAssertEqual(subject.type, expectedType)
        XCTAssertEqual(subject.size, 0x02)
        XCTAssertEqual(subject.reason, "")
    }
    
    func testCloseRedirectFrameCreatedCorrectly() {
        let expectedType = BaseFrame(type: FrameType.Close_Redirect)
        let subject = CloseRedirectFrame(size: 0x02, url: "CloseRedirectFrame")
        XCTAssertEqual(subject.type, expectedType)
        XCTAssertEqual(subject.size, 0x02)
        XCTAssertEqual(subject.url, "CloseRedirectFrame")
    }
    
    func testUserMessageHeaderFrameCreatedCorrectly() {
        let subject = UserMessageHeaderFrame(uid: [0x1, 0x2, 0x3, 0x4], size: 0x01, uri: "uri")
        XCTAssertEqual(subject.uid, [0x1, 0x2, 0x3, 0x4])
        XCTAssertEqual(subject.size, 0x01)
        XCTAssertEqual(subject.uri, "uri")
    }
    
    func testUserMessageHeaderFrameAreEqual() {
        let subjectA = UserMessageHeaderFrame(uid: [0x1, 0x2, 0x3, 0x4], size: 0x01, uri: "uri")
        let subjectB = UserMessageHeaderFrame(uid: [0x1, 0x2, 0x3, 0x4], size: 0x01, uri: "uri")
        XCTAssertEqual(subjectA, subjectB)
    }
    
    func testUserMessageHeaderFrameAreNotEqualWithDifferentUids() {
        let subjectA = UserMessageHeaderFrame(uid: [0x1, 0x2, 0x4], size: 0x01, uri: "uri")
        let subjectB = UserMessageHeaderFrame(uid: [0x1, 0x2, 0x3, 0x4], size: 0x01, uri: "uri")
        XCTAssertNotEqual(subjectA, subjectB)
    }
    
    func testUserMessageBodyFrameCreatedCorrectly() {
        let subject = UserMessageBodyFrame(size: 0x01, body: [0x00, 0x01])
        XCTAssertEqual(subject.size, 0x01)
        XCTAssertEqual(subject.body!, [0x00, 0x01])
    }
    
    func testUserMessageBodyFrameWithNilBodyCreatedCorrectly() {
        let subject = UserMessageBodyFrame(size: 0x01, body: nil)
        XCTAssertEqual(subject.size, 0x01)
        XCTAssertEqual(subject.body!, [])
    }
    
    func testUserMessageBodyFramesAreEqual() {
        let subjectA = UserMessageBodyFrame(size: 0x01, body: [0x00, 0x01])
        let subjectB = UserMessageBodyFrame(size: 0x01, body: [0x00, 0x01])
        XCTAssertEqual(subjectA, subjectB)
    }
    
    func testUserMessageBodyFramesAreNotEqual() {
        let subjectA = UserMessageBodyFrame(size: 0x01, body: [0x00, 0x01])
        let subjectB = UserMessageBodyFrame(size: 0x01, body: [0x00])
        XCTAssertNotEqual(subjectA, subjectB)
    }
    
    func testUserMessageBodyFramesAreEqualWithNilBody() {
        let subjectA = UserMessageBodyFrame(size: 0x01, body: nil)
        let subjectB = UserMessageBodyFrame(size: 0x01, body: nil)
        XCTAssertEqual(subjectA, subjectB)
    }
    
    func testEventFrameCreatedCorrectly() {
        let header = UserMessageHeaderFrame(uid: [0x1, 0x2, 0x4], size: 0x01, uri: "uri")
        let body = UserMessageBodyFrame(size: 0x01, body: [0x00, 0x01])
        let subject = EventFrame(header: header, body: body)
        XCTAssertEqual(subject.header, header)
        XCTAssertEqual(subject.body, body)
    }
    
    func testRequestFrameCreatedCorrectly() {
        let header = UserMessageHeaderFrame(uid: [0x1, 0x2, 0x4], size: 0x01, uri: "uri")
        let body = UserMessageBodyFrame(size: 0x01, body: [0x00, 0x01])
        let subject = RequestFrame(header: header, isProgressive: true, body: body)
        XCTAssertEqual(subject.header, header)
        XCTAssertEqual(subject.isProgressive, true)
        XCTAssertEqual(subject.body, body)
    }
    
    
    func testCancelFrameCreatedCorrectly() {
        let header = UserMessageHeaderFrame(uid: [0x1, 0x2, 0x4], size: 0x01, uri: "uri")
        let subject = CancelFrame(header: header, requestUid: [0x00, 0x01], kill: true)
        XCTAssertEqual(subject.header, header)
        XCTAssertEqual(subject.requestUid, [0x00, 0x01])
        XCTAssertEqual(subject.kill, true)
    }
    
    func testResponseFrameCreatedCorrectly() {
        let body = UserMessageBodyFrame(size: 0x01, body: [0x00, 0x01])
        let header = UserMessageHeaderFrame(uid: [0x1, 0x2, 0x4], size: 0x01, uri: "uri")
        let subject = ResponseFrame(header: header, requestUid: [0x00, 0x01], responseType: ResponseType.done, body: body)
        XCTAssertEqual(subject.header, header)
        XCTAssertEqual(subject.requestUid, [0x00, 0x01])
        XCTAssertEqual(subject.responseType, ResponseType.done)
        XCTAssertEqual(subject.body, body)
    }
    
}
