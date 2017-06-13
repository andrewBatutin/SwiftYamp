//
//  DeserializerTest.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/13/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import XCTest
@testable import SwiftYamp

class DeserializerTest: XCTestCase {
    
    func testFrameTypeSerializationSuccsesfyll() {
        let inputData = Data(bytes: [0x00])
        let realFrame:BaseFrame = try! serialize(data: inputData)
        let expectedFrame:BaseFrame = BaseFrame(type: FrameType.Handshake)
        XCTAssertEqual(realFrame, expectedFrame)
    }
    
    func testFrameTypeSerializationWrongInputDataThorwsError() {
        let inputData = Data(bytes: [0x99])
        let realFrame:BaseFrame? = try? serialize(data: inputData)
        XCTAssertNil(realFrame)
    }
    
    func testFrameTypeSerializationEmptyInputDataThorwsError() {
        let inputData = Data(bytes: [])
        let realFrame:BaseFrame? = try? serialize(data: inputData)
        XCTAssertNil(realFrame)
    }
    
    func testSomeSwiftShit() {
        let inputData = Data(bytes: [0x00])
        let s:BaseFrame = try! serializeT(data: inputData)
        
    }
    
    func testHandshakeSerializationWithValidInput() {
        let inputData = Data(bytes: [0x00, 0x01, 0x00, 0x04, 0x41, 0x41, 0x41, 0x41])
        let subject = try! HandshakeFrame(data: inputData)
        XCTAssertEqual(subject.type, BaseFrame(type: FrameType.Handshake))
        XCTAssertEqual(subject.version, 0x01)
        XCTAssertEqual(subject.size, 0x04)
        XCTAssertEqual(subject.serializer, "AAAA")
    }
    
    func testHandshakeSerializationWithToShortFrame() {
        let inputData = Data(bytes: [0x00, 0x01, 0x00, 0x04, 0x41, 0x41, 0x41])
        XCTAssertThrowsError( try HandshakeFrame(data: inputData) )
    }
    
    func testHandshakeSerializationWithemptyFrame() {
        let inputData = Data(bytes: [])
        XCTAssertThrowsError( try HandshakeFrame(data: inputData) )
    }
    
    func testPingSerializationWithValidInput() {
        let inputData = Data(bytes: [0x01, 0x04, 0x41, 0x41, 0x41, 0x41])
        let subject = try! PingFrame(data: inputData)
        XCTAssertEqual(subject.type, BaseFrame(type: FrameType.Ping))
        XCTAssertEqual(subject.size, 0x04)
        XCTAssertEqual(subject.payload, "AAAA")
    }
    
    func testPingSerializationWithValidInputEmptyPayload() {
        let inputData = Data(bytes: [0x01, 0x00])
        let subject = try! PingFrame(data: inputData)
        XCTAssertEqual(subject.type, BaseFrame(type: FrameType.Ping))
        XCTAssertEqual(subject.size, 0x0)
        XCTAssertEqual(subject.payload, "")
    }
    
    func testPingSerializationWithInValidInputWrongPayload() {
        let inputData = Data(bytes: [0x01, 0x04, 0x41, 0x41, 0x41])
        XCTAssertThrowsError( try PingFrame(data: inputData) )
    }
    
    func testPongSerializationWithValidInput() {
        let inputData = Data(bytes: [0x02, 0x04, 0x41, 0x41, 0x41, 0x41])
        let subject = try! PongFrame(data: inputData)
        XCTAssertEqual(subject.type, BaseFrame(type: FrameType.Pong))
        XCTAssertEqual(subject.size, 0x04)
        XCTAssertEqual(subject.payload, "AAAA")
    }
    
    func testPongSerializationWithValidInputEmptyPayload() {
        let inputData = Data(bytes: [0x02, 0x00])
        let subject = try! PongFrame(data: inputData)
        XCTAssertEqual(subject.type, BaseFrame(type: FrameType.Pong))
        XCTAssertEqual(subject.size, 0x0)
        XCTAssertEqual(subject.payload, "")
    }
    
    func testPongSerializationWithInValidInputWrongPayload() {
        let inputData = Data(bytes: [0x02, 0x04, 0x41, 0x41, 0x41])
        XCTAssertThrowsError( try PongFrame(data: inputData) )
    }
    
    func testCloseFrameSerializationWithValidInput() {
        let inputData = Data(bytes: [0x03, 0x04, 0x00, 0x41, 0x41, 0x41, 0x41])
        let subject = try! CloseFrame(data: inputData)
        XCTAssertEqual(subject.type, BaseFrame(type: FrameType.Close))
        XCTAssertEqual(subject.size, 0x04)
        XCTAssertEqual(subject.reason, "AAAA")
    }
    
    func testCloseFrameSerializationWithInValidInputShortReason() {
        let inputData = Data(bytes: [0x03, 0x04, 0x00, 0x41, 0x41, 0x41])
        XCTAssertThrowsError( try CloseFrame(data: inputData) )
    }
    
    func testCloseFrameSerializationWithValidInputEmptyReason() {
        let inputData = Data(bytes: [0x02, 0x00, 0x00])
        let subject = try! CloseFrame(data: inputData)
        XCTAssertEqual(subject.type, BaseFrame(type: FrameType.Close))
        XCTAssertEqual(subject.size, 0x0)
        XCTAssertEqual(subject.reason, "")
    }
    
    func testCloseRedirectFrameSerializationWithValidInput() {
        let inputData = Data(bytes: [0x03, 0x04, 0x00, 0x41, 0x41, 0x41, 0x41])
        let subject = try! CloseRedirectFrame(data: inputData)
        XCTAssertEqual(subject.type, BaseFrame(type: FrameType.Close_Redirect))
        XCTAssertEqual(subject.size, 0x04)
        XCTAssertEqual(subject.url, "AAAA")
    }
    
    func testCloseRedirectFrameSerializationWithInValidInputShortReason() {
        let inputData = Data(bytes: [0x03, 0x04, 0x00, 0x41, 0x41, 0x41])
        XCTAssertThrowsError( try CloseRedirectFrame(data: inputData) )
    }
    
    func testCloseRedirectFrameSerializationWithInValidInputShortSize() {
        let inputData = Data(bytes: [0x03, 0x04])
        XCTAssertThrowsError( try CloseRedirectFrame(data: inputData) )
    }
    
}
