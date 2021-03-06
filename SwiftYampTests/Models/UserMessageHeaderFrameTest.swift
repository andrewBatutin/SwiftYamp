//
//  UserMessageHeaderFrameTest.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/13/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import XCTest
@testable import SwiftYamp

class UserMessageHeaderFrameTest: XCTestCase {
    
    func testUserMessageHeaderSerializationSuccsefull(){
        let expectedData = Data(bytes: [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x41, 0x41, 0x41, 0x41])
        let subject = UserMessageHeaderFrame(uid: [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], size: 4, uri: "AAAA")
        let realData = try! subject.toData()
        XCTAssertEqual(realData, expectedData)
    }
    
    func testUserMessageHeaderDeSerializationThrowsWithShortData(){
        let inputData = Data(bytes: [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x41, 0x41, 0x41, 0x41])
        XCTAssertThrowsError(try UserMessageHeaderFrame(data: inputData))
    }
    
    func testUserMessageHeaderDeSerializationSuccsefull(){
        let inputData = Data(bytes: [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x41, 0x41, 0x41, 0x41])
        let subject = try! UserMessageHeaderFrame(data: inputData)
        XCTAssertEqual(subject.uid, [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        XCTAssertEqual(subject.size, 0x04)
        XCTAssertEqual(subject.uri, "AAAA")
    }
    
}
