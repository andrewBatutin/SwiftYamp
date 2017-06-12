//
//  BaseFrameTest.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/12/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import XCTest
@testable import SwiftYamp

class BaseFrameTest: XCTestCase {
    
    func testFrameTypeIsSetCorrectly() {
        let subject = BaseFrame(type: FrameType.Handshake)
        XCTAssertEqual(subject.type, FrameType.Handshake)
    }
    
}
