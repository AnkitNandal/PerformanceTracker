//
//  KPTimeManager.swift
//  KP
//
//  Created by Ankit Nandal on 21/02/18.
//  Copyright © 2018 Ankit Nandal. All rights reserved.
//

import Foundation


struct Time{
    static func current() -> CFAbsoluteTime {
        return CFAbsoluteTimeGetCurrent()
    }
    
    static func elapsed(from old:CFAbsoluteTime) ->ElapsedTime{
        return Time.current() - old
    }
}

/* the reference date (epoch) is 00:00:00 1 January 2001. */
struct TimeManager {
    
    var start:CFTimeInterval
    var end:CFTimeInterval?
    
    var elapsed:ElapsedTime {
        if let endTime = self.end {
            return (endTime - start)*1000
        } else {
            return 0
        }
    }
    
    init (time:CFTimeInterval=Time.current()) {
        self.start = time
    }

    
    mutating func stop() {
       self.end = Time.current()
    }
}
