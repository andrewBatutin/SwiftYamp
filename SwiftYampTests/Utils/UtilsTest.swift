//
//  Utils.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/21/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import XCTest

class UtilsTest: XCTestCase {
    
    func testUidCreation(){
        let res = messageUuid()
        XCTAssertNotNil(res)
        XCTAssertTrue(res.count == 16)
    }
    
    func testUidAreUnique(){
        let resA = messageUuid()
        let resB = messageUuid()
        XCTAssertNotEqual(resA, resB)
    }

}
