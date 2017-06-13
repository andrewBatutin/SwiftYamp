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
    
    
}
