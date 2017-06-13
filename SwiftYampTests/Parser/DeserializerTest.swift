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
    
    func testHandshakeSerialization() {
        let inputData = Data(bytes: [0x00, 0x01, 0x00, 0x04, 0x41, 0x41, 0x41, 0x41])
        let h = HandshakeFrame(data: inputData)
        XCTAssertNotNil(h)
    }
    
}
