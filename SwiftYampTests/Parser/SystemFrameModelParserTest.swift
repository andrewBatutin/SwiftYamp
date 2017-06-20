//
//  DeserializerTest.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/13/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import XCTest
@testable import SwiftYamp

class SystemFrameModelParserTest: XCTestCase {
    
    func testHandshakeDeSerializationWithValidInput() {
        let inputData = Data(bytes: [0x00, 0x00, 0x01, 0x04, 0x41, 0x41, 0x41, 0x41])
        let subject = try! HandshakeFrame(data: inputData)
        XCTAssertEqual(subject.type, BaseFrame(type: FrameType.Handshake))
        XCTAssertEqual(subject.version, 0x01)
        XCTAssertEqual(subject.size, 0x04)
        XCTAssertEqual(subject.serializer, "AAAA")
    }
    
    func testHandshakeDeSerializationWithToShortFrame() {
        let inputData = Data(bytes: [0x00, 0x00, 0x01, 0x04, 0x41, 0x41, 0x41])
        XCTAssertThrowsError( try HandshakeFrame(data: inputData) )
    }
    
    func testHandshakeDeSerializationWithemptyFrame() {
        let inputData = Data(bytes: [])
        XCTAssertThrowsError( try HandshakeFrame(data: inputData) )
    }
    
    func testHandshakeFrameSerializationSuccsefull(){
        let expectedData = Data(bytes: [0x00, 0x00, 0x01, 0x04, 0x41, 0x41, 0x41, 0x41])
        let subject = HandshakeFrame(version: 1, size: 4, serializer: "AAAA")
        let realData = try! subject.toData()
        XCTAssertEqual(realData, expectedData)
    }
    
    func testPingDeSerializationWithValidInput() {
        let inputData = Data(bytes: [0x02, 0x01, 0x04, 0x41, 0x41, 0x41, 0x41])
        let subject = try! PingFrame(data: inputData)
        XCTAssertEqual(subject.type, BaseFrame(type: FrameType.Ping))
        XCTAssertEqual(subject.size, 0x04)
        XCTAssertEqual(subject.payload, "AAAA")
    }
    
    func testPingDeSerializationWithValidInputEmptyPayload() {
        let inputData = Data(bytes: [0x02, 0x01, 0x00])
        let subject = try! PingFrame(data: inputData)
        XCTAssertEqual(subject.type, BaseFrame(type: FrameType.Ping))
        XCTAssertEqual(subject.size, 0x0)
        XCTAssertEqual(subject.payload, "")
    }
    
    func testPingDeSerializationWithInValidInputWrongPayload() {
        let inputData = Data(bytes: [0x02, 0x01, 0x04, 0x41, 0x41, 0x41])
        XCTAssertThrowsError( try PingFrame(data: inputData) )
    }
    
    func testPingFrameSerializationSuccsefull(){
        let expectedData = Data(bytes: [0x02, 0x01, 0x04, 0x41, 0x41, 0x41, 0x41])
        let subject = PingFrame(ack: true, size: 4, payload: "AAAA")
        let realData = try! subject.toData()
        XCTAssertEqual(realData, expectedData)
    }
    
    func testPingFrameSerializationSuccsefullWithoutPayload(){
        let expectedData = Data(bytes: [0x02, 0x01, 0x00])
        let subject = PingFrame(ack: true, size: 0, payload: "")
        let realData = try! subject.toData()
        XCTAssertEqual(realData, expectedData)
    }
    
    func testPingFrameSerializationSuccsefullWithNilPayload(){
        let expectedData = Data(bytes: [0x02, 0x01, 0x00])
        let subject = PingFrame(ack: true, size: 0, payload: nil)
        let realData = try! subject.toData()
        XCTAssertEqual(realData, expectedData)
    }
    
    func testCloseFrameDeSerializationWithValidInput() {
        let inputData = Data(bytes: [0x01, 0x03, 0x00, 0x04, 0x41, 0x41, 0x41, 0x41])
        let subject = try! CloseFrame(data: inputData)
        XCTAssertEqual(subject.type, BaseFrame(type: FrameType.Close))
        XCTAssertEqual(subject.size, 0x04)
        XCTAssertEqual(subject.message, "AAAA")
        XCTAssertEqual(subject.closeCode, CloseCodeType.Redirect)
    }
    
    func testCloseFrameDeSerializationWithInValidInputWrongCloseCode() {
        let inputData = Data(bytes: [0x01, 0x99, 0x00, 0x04, 0x41, 0x41, 0x41])
        XCTAssertThrowsError( try CloseFrame(data: inputData) )
    }
    
    func testCloseFrameDeSerializationWithInValidInputShortReason() {
        let inputData = Data(bytes: [0x01, 0x03, 0x00, 0x04, 0x41, 0x41, 0x41])
        XCTAssertThrowsError( try CloseFrame(data: inputData) )
    }
    
    func testCloseFrameDeSerializationWithValidInputEmptyReason() {
        let inputData = Data(bytes: [0x01, 0x03, 0x00, 0x00])
        let subject = try! CloseFrame(data: inputData)
        XCTAssertEqual(subject.type, BaseFrame(type: FrameType.Close))
        XCTAssertEqual(subject.size, 0x0)
        XCTAssertEqual(subject.message, "")
    }
    
    func testCloseFrameSerializationSuccsefullWithPayload(){
        let expectedData = Data(bytes: [0x01, 0x03, 0x00, 0x04, 0x41, 0x41, 0x41, 0x41])
        let subject = CloseFrame(closeCode: CloseCodeType.Redirect, size: 4, reason: "AAAA")
        let realData = try! subject.toData()
        XCTAssertEqual(realData, expectedData)
    }
    
    func testCloseFrameSerializationSuccsefullWithoutPayload(){
        let expectedData = Data(bytes: [0x01, 0x03, 0x00, 0x00])
        let subject = CloseFrame(closeCode: CloseCodeType.Redirect, size: 0, reason: nil)
        let realData = try! subject.toData()
        XCTAssertEqual(realData, expectedData)
    }
        
}
