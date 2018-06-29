//
//  KPLogFormatter.swift
//  KP
//
//  Created by Ankit Nandal on 21/02/18.
//  Copyright © 2018 Ankit Nandal. All rights reserved.
//

import Foundation


struct LogFormatter {
    static let headerText  = getHeaderText()
    static var columns = ["TransactionId","Type","Subtype","Comment","Class Name","Line Number","Function","Start Time","End Time","Duration","Status","Data Size","Main Thread?"]
    
    private static func getHeaderText() -> String{
        let combinedStr = LogFormatter.columns.joined(separator: ",") + "\n"
        return  combinedStr
    }
    
    static func getLogString(from log:KPLog) -> String{
        var passedBenchmarking = log.isPassed ? "Passed":"Failed"
        let threadInfo = log.isMainThreadWhenFinished == true ?"Main Thread" :"Background Thread"

        var dataSize = "n/a"
        if let data = log.dataSize {
            dataSize =  "\(String(describing:data)) KB"
        }
        
        var taskEnd = ""
        if let taskEndTime = log.taskEnd {
          taskEnd = "\(taskEndTime)"
        } else {
            taskEnd = "Task not ended properly!"
            passedBenchmarking = "Unknown"
        }
        
        let type = log.type.Identifier
        let subType = log.subType ?? "-"
        let fileName = log.fileName.components(separatedBy: "/").last ?? "-"
        
        return "\(log.id), \(type),\(subType),\(log.comments ?? "-"),\(fileName ),\(log.lineNumber),\(log.function),\(String(describing: log.taskStarted)),\(taskEnd),\(String(format: "%.0f", log.taskElapsed)) ms,\(passedBenchmarking),\(dataSize),\(threadInfo)\n"
    }
}
