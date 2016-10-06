//
//  ContainerExtensions.swift
//  XcodeServerSDK
//
//  Created by Honza Dvorsky on 21/06/2015.
//  Copyright © 2015 Honza Dvorsky. All rights reserved.
//

import Foundation

extension Sequence {
    
    public func mapThrows<T>(transform: (Self.Iterator.Element) throws -> T) rethrows -> [T] {
        
        var out: [T] = []
        for i in self {
            out.append(try transform(i))
        }
        return out
    }
    
    public func filterThrows(includeElement: (Self.Iterator.Element) throws -> Bool) rethrows -> [Self.Iterator.Element] {
        
        var out: [Self.Iterator.Element] = []
        for i in self {
            if try includeElement(i) {
                out.append(i)
            }
        }
        return out
    }
    
    /**
    Basically `filter` that stops when it finds the first one.
    */
    public func findFirst(_ test: (Self.Iterator.Element) -> Bool) -> Self.Iterator.Element? {
        
        for i in self {
            if test(i) {
                return i
            }
        }
        return nil
    }
}
