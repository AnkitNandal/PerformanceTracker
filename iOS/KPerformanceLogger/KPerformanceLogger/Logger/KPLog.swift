//
//  KPLog
//  KPerformanceLogger
//
//  Created by Ankit Nandal on 30/01/18.
//  Copyright © 2018 Ankit Nandal. All rights reserved.
//

import Foundation

/**
 It is a log model class that holds all the information of a particular tasks. For example, any network track record for a particular feature. Generally there will be multiple log records under a feature. All the records across a feature will be consolidated under a KPLogger record.
 */
class KPLog {
    /**
     A counter which auto increments each time an instance of KPLog is created.
     */
    static var logCounter:UInt = 0
    
    /**
     Parent transaction id for any log record.
     */
    var id:TransactionId
    
    /**
     It determines for which type does this current log belongs. For more info see **LogType** enum.
     */
    
    var type:LogType
    /**
     It shows subtype under any primitive type. For example, there may be multiple network calls across a feature.
     */
    
    var subType:String?
    
    /**
     It keeps any comment that we want to keep across any record.
     */
    var comments:String?
    
    /**
     Name of the file from where this log record has been initialted.
     */
    var fileName:String
    
    /**
     Line number of the file from where this log record has been initialted.
     */
    var lineNumber:UInt
    
    /**
     Function Name from where this log record. has been initialted.
     */
    var function:String
    
    /**
     It holds start time and end time of a particular log.
     */
    var timeManager: TimeManager
    
    /**
     Status of the record whether its started, cancelled,etc.
     */
    var status:LogStatus
    
    /**
     It holds the information whether the task is on main thread or not.
     */
    var isMainThreadWhenStarted:Bool
    
    /**
     It holds the information whether the task was on main thread or not when it finished logging.
     */
    var isMainThreadWhenFinished:Bool?
    
    /**
     Data size in bytes for some particular types.
     */
    var dataSize:Double?
    
    /**
     Whether a log record has finished tracking.
     */
    var finished:Bool = false
    
    /**
     It will determine whether a log has passed it benchmark time.
     */
    var isPassed:Bool {
        return KPBenchmark.didOperationPassedBenchmarking(from: self.type, time: taskElapsed, size: dataSize)
    }
    
    /**
     When would the task started.
     */
    var taskStarted:CFTimeInterval{
        return self.timeManager.start
    }
    
    /**
     When did the task end.
     */
    var taskEnd:CFTimeInterval?{
        return self.timeManager.end
    }
    
    /**
     Time elapsed for a log record.
     */
    var taskElapsed:ElapsedTime{
        return timeManager.elapsed
    }
    
    /**
     Name of the class for which this log has been generated.
     */
    var className:String{
        return self.fileName.components(separatedBy: "/").last ?? self.fileName
    }
    
    /**
     Initilize a log record with proper info.
     
        - Parameters:
            - info : Loginfo model containing all the initial informations required to start tracking a log.
     */
    init(logInfo info:LogInfo) {
        status = .started
        type = info.logType
        id = info.transactionId
        comments = info.comment
        fileName = info.filename
        lineNumber = info.lineNumber
        function = info.functionName
        timeManager = TimeManager(time: info.startTime)
        if let size = Double(info.dataSize?.components(separatedBy: "KB").first?.trimmingCharacters(in: .whitespaces) ?? ""){
            self.dataSize = size
        }
        isMainThreadWhenStarted = info.isMainThread
        subType = info.subType
        KPLog.logCounter += 1
    }
    
    /**
     Stop time tracking for a log.
     
     - Parameters:
        - status : How a log ended tracking, whether it successfully stopped or due to timeout it closed.
     */
    func stopTimeTracking(with status:LogStatus = .success) {
        isMainThreadWhenFinished = Thread.isMainThread
        self.status = status
        timeManager.stop()
        if finished{
            comments = "Log closed multiple times. Please check."
        }
        finished = true
    }
    
    /**
     Final log report string with proper format that must be passes to its parent to generate log report in appropriate report.
    */
    var report :String {
        return LogFormatter.getLogString(from: self)
    }
    
    deinit {
//        print("KPLogg Deinit :\(self.id)-\(self.type.toString)")
    }
}


