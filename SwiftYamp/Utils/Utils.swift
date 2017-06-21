//
//  Utils.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/21/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import Foundation


func messageUuid() -> [UInt8]{
    let uid = UUID()
    let uuidBytes = Mirror(reflecting: uid.uuid).children.map { $0.1 as! UInt8 }    
    return uuidBytes
}
