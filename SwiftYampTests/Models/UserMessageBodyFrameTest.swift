//
//  UserMessageBodyFrameTest.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/13/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//


import XCTest
@testable import SwiftYamp

class UserMessageBodyFrameTest: XCTestCase {
    
    func testUserMessageHeaderSerializationSuccsefull(){
        let expectedData = Data(bytes: [0x04, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03, 0x04])
        let subject = UserMessageBodyFrame(size: 4, body: [0x01, 0x02, 0x03, 0x04])
        let realData = try! subject.toData()
        XCTAssertEqual(realData, expectedData)
    }
    
    func testUserMessageHeaderDeSerializationThrowsWithShortData(){
        let inputData = Data(bytes: [0x04, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03])
        XCTAssertThrowsError(try UserMessageBodyFrame(data: inputData))
    }
    
    func testUserMessageHeaderDeSerializationSuccsefull(){
        let inputData = Data(bytes: [0x04, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03, 0x04])
        let subject = try! UserMessageBodyFrame(data: inputData)
        XCTAssertEqual(subject.size, 0x04)
        XCTAssertEqual(subject.body!, [0x01, 0x02, 0x03, 0x04])
    }
    
}
