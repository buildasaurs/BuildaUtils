//
//  Ref.swift
//  BuildaUtils
//
//  Created by Honza Dvorsky on 10/3/15.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

//for serialization of object references
public typealias RefType = String

public struct Ref {
    public static func new() -> RefType {
        return NSUUID().UUIDString
    }
}
