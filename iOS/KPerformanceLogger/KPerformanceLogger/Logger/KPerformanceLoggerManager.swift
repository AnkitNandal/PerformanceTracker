//
//  KPerformanceLoggerManager
//  KPerformanceLogger
//
//  Created by Ankit Nandal on 28/12/17.
//  Copyright © 2017 Ankit Nandal. All rights reserved.
//

import Foundation
import UIKit

//@objcMembers
open class KPerformanceLoggerManager:NSObject{
    // MARK: - Properties
    public static var shared = KPerformanceLoggerManager()
    /**
     It contains all the logs that are currently active.
     */
    fileprivate var activeLogs:[TransactionId:KPLogger] = [:]
    /**
     It contains all the logs that have finished tracking and are ready to be offload.
     */
    fileprivate var finishedLogs:[KPLogger] = []
    
    fileprivate var device = Device.current
    /**
     Operation Queue used to take taska offload main thread.
     */
    fileprivate var opQueue = OperationQueue()
    
    /**
     A private dispatch Queue to make all the active logs and finished logs access thread safe.
     */
    fileprivate var dispatchQueue:DispatchQueue!

    /**
     A count which will be used to flush out all the finished logs to disk.
     */
    fileprivate var flushCount:UInt{
        return KPLoggerConfiguration.shared.fulshCount
    }
    
    /**
     A flag that will decide whether all the logs will be tracked or not.
     */
    fileprivate var shouldTrack:Bool {
        return KPLoggerConfiguration.shared.enable
    }
    

    // MARK: - Initilizer
    override private init() {
        super.init()
        
        dispatchQueue = DispatchQueue(label: KPLoggerConstants.perfromanceLoggerQueue)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.saveSessionData), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
        
    }
}

// MARK: - KPerformanceLoggerManager Methods
extension KPerformanceLoggerManager {
    /**
     Start tracking for a UI rendering task.
     
     - Parameters:
        - transactionId: Transaction id to be used for tracking events of a feature. It's an id which will be               unique across all the primitive types which will be tacked across a particular feature.
        - subType: Any subtype apart from main primitive type. It is generally used if there are more than one primitive task that fall under same feature. For example, if there are more that one UI rendering tasks under one feature. In that case we must provide unique value for each UI subtype.
        - comment: Any comments that are to be attached for a particular type.
        - fileName: The file name to print. The default is the file where `startUI` is called.
        - lineNumber: The line number to print. The default is the line number where `startUI`
        - functionName: The line number to print. The default is name of the function from where `startUI`
     is called.
     */
    open class func startUI(transactionId id:TransactionId?,subType type:String? = nil, comment:String?=nil,
                            fileName: String = #file, lineNumber: UInt = #line, functionName: String = #function) {
        guard shared.shouldTrack else {return}
        guard let tId  = id else {return}
        KPerformanceLoggerManager.start(with:  KPerformanceLoggerManager.getLogInfoModel(logType: .userInterface, transactionId: tId,subType:type, comment: comment,fileName,lineNumber: lineNumber,functionName: functionName))
    }
    
    /**
     Call this method whenever you want to stop tracking an ongoing UI task.
     
     - Parameters:
        - transactionId: Transaction id to be used for tracking events of a feature. It's an id which will be               unique across all the primitive types which will be tacked across a particular feature.
        - subType: Any subtype apart from main primitive type. It is generally used if there are more than one primitive task that fall under same feature. For example, if there are more that one UI rendering tasks under one feature. In that case we must provide unique value for each UI subtype.
     */
    open class func stopUI(transactionId id:TransactionId?,subType uiSubtype:String? = nil) {
        guard shared.shouldTrack else {return}
        guard let tId  = id else {return}
        KPerformanceLoggerManager.end(logType: .userInterface, transactionId: tId,subType:uiSubtype)
    }
    
    /**
     Start tracking for a Network task.
     
     - Parameters:
        - transactionId: Transaction id to be used for tracking events of a feature. It's an id which will be               unique across all the primitive types which will be tacked across a particular feature.
        - subType: Any subtype apart from main primitive type. It is generally used if there are more than one primitive task that fall under same feature. For example, if there are more that one UI rendering tasks under one feature. In that case we must provide unique value for each UI subtype.
        - comment: Any comments that are to be attached for a particular type.
        - fileName: The file name to print. The default is the file where `startUI` is called.
        - lineNumber: The line number to print. The default is the line number where `startUI`
        - functionName: The line number to print. The default is name of the function from where `startUI`
     is called.
     */
    open class func startNetwork(transactionId id:TransactionId?,subType type:String? = nil, comment:String?=nil,
                                 fileName: String = #file, lineNumber: UInt = #line, functionName: String = #function) {
        guard shared.shouldTrack else {return}
        guard let tId  = id else {return}
        KPerformanceLoggerManager.start(with:  KPerformanceLoggerManager.getLogInfoModel(logType: .network, transactionId: tId,subType:type, comment: comment,fileName,lineNumber: lineNumber,functionName: functionName))
    }
    
    /**
     Call this method whenever you want to stop tracking an ongoing n/w task.
     
     - Parameters:
        - transactionId: Transaction id to be used for tracking events of a feature. It's an id which will be               unique across all the primitive types which will be tacked across a particular feature.
        - subType: Any subtype apart from main primitive type. It is generally used if there are more than one primitive task that fall under same feature. For example, if there are more that one UI rendering tasks under one feature. In that case we must provide unique value for each UI subtype.
     */
    open class func stopNetwork(transactionId id:TransactionId?,subType requestSubType:String? = nil) {
        guard shared.shouldTrack else {return}
        guard let tId  = id else {return}
        KPerformanceLoggerManager.end(logType: .network, transactionId: tId,subType:requestSubType)
    }
    
    /**
     Start tracking for a Network response Parsing task.
     
     - Parameters:
        - transactionId: Transaction id to be used for tracking events of a feature. It's an id which will be               unique across all the primitive types which will be tacked across a particular feature.
        - subType: Any subtype apart from main primitive type. It is generally used if there are more than one primitive task that fall under same feature. For example, if there are more that one UI rendering tasks under one feature. In that case we must provide unique value for each UI subtype.
        - size: Size of received data in bytes.
        - comment: Any comments that are to be attached for a particular type.
        - fileName: The file name to print. The default is the file where `startUI` is called.
        - lineNumber: The line number to print. The default is the line number where `startUI`
        - functionName: The line number to print. The default is name of the function from where `startUI`
     is called.
     */
    open class func startParsing(transactionId id:TransactionId?,subType type:String? = nil,size:String?, comment:String?=nil,
                                 fileName: String = #file, lineNumber: UInt = #line, functionName: String = #function) {
        guard shared.shouldTrack else {return}
        guard let tId  = id else {return}
        KPerformanceLoggerManager.start(with:  KPerformanceLoggerManager.getLogInfoModel(logType: .parsing, transactionId: tId,subType:type, size:size,comment: comment,fileName,lineNumber: lineNumber,functionName: functionName))
    }
    
    /**
     Call this method whenever you want to stop tracking an ongoing network response Parsing task.
     
     - Parameters:
        - transactionId: Transaction id to be used for tracking events of a feature. It's an id which will be               unique across all the primitive types which will be tacked across a particular feature.
        - subType: Any subtype apart from main primitive type. It is generally used if there are more than one primitive task that fall under same feature. For example, if there are more that one UI rendering tasks under one feature. In that case we must provide unique value for each UI subtype.
     */
    open class func stopParsing(transactionId id:TransactionId?,subType requestSubType:String? = nil) {
        guard shared.shouldTrack else {return}
        guard let tId  = id else {return}
        KPerformanceLoggerManager.end(logType: .parsing, transactionId: tId,subType:requestSubType)
    }
    
    /**
     Start tracking for a CoreData task.
     
     - Parameters:
        - transactionId: Transaction id to be used for tracking events of a feature. It's an id which will be               unique across all the primitive types which will be tacked across a particular feature.
        - subType: Any subtype apart from main primitive type. It is generally used if there are more than one primitive task that fall under same feature. For example, if there are more that one UI rendering tasks under one feature. In that case we must provide unique value for each UI subtype.
        - comment: Any comments that are to be attached for a particular type.
        - fileName: The file name to print. The default is the file where `startUI` is called.
        - lineNumber: The line number to print. The default is the line number where `startUI`
        - functionName: The line number to print. The default is name of the function from where `startUI`
     is called.
     */
    open class func startCoreData(transactionId id:TransactionId?,subType type:String? = nil, comment:String?=nil,
                                  fileName: String = #file, lineNumber: UInt = #line, functionName: String = #function) {
        guard shared.shouldTrack else {return}
        guard let tId  = id else {return}
        KPerformanceLoggerManager.start(with:  KPerformanceLoggerManager.getLogInfoModel(logType: .coreData, transactionId: tId,subType:type, comment: comment,fileName,lineNumber: lineNumber,functionName: functionName))
        
    }
    
    /**
     Call this method whenever you want to stop tracking an ongoing CoreData task.
     
     - Parameters:
        - transactionId: Transaction id to be used for tracking events of a feature. It's an id which will be               unique across all the primitive types which will be tacked across a particular feature.
        - subType: Any subtype apart from main primitive type. It is generally used if there are more than one primitive task that fall under same feature. For example, if there are more that one UI rendering tasks under one feature. In that case we must provide unique value for each UI subtype.
     */
    open class func stopCoreData(transactionId id:TransactionId?,subType requestSubType:String? = nil) {
        guard shared.shouldTrack else {return}
        guard let tId  = id else {return}
        KPerformanceLoggerManager.end(logType: .coreData, transactionId: tId,subType:requestSubType)
    }
    
    /**
     Start tracking any custom action that is not available primitively. Here we can start tracking any custom task that we wnat to. For example , there may be a View Model creator task that we are doiung before populating data. So in this case we must pass a custom type along with transaction Id.
     
     - Parameters:
        - transactionId: Transaction id to be used for tracking events of a feature. It's an id which will be               unique across all the primitive types which will be tacked across a particular feature.
        - type: Any custom subtype apart from main primitive type. It shoud be unique to clearly mention specific custom task.
        - comment: Any comments that are to be attached for a particular type.
        - fileName: The file name to print. The default is the file where `startUI` is called.
        - lineNumber: The line number to print. The default is the line number where `startUI`
        - functionName: The line number to print. The default is name of the function from where `startUI`
     is called.
     */
    open class func startCustomAction(transactionId id:TransactionId?, type customType:String,comment:String?=nil,  fileName: String = #file, lineNumber: UInt = #line, functionName: String = #function) {
        guard shared.shouldTrack else {return}
        guard let tId  = id else {return}
        KPerformanceLoggerManager.start(with:  KPerformanceLoggerManager.getLogInfoModel(logType: .custom(customType), transactionId: tId, comment: comment,fileName,lineNumber: lineNumber,functionName: functionName))
    }
    
    /**
     Call this method whenever you want to stop tracking an ongoing custom task.
     
     - Parameters:
        - transactionId: Transaction id to be used for tracking events of a feature. It's an id which will be               unique across all the primitive types which will be tacked across a particular feature.
        - type: Any custom subtype apart from main primitive type. It shoud be unique to clearly mention specific custom task.
     */
    open class func stopCustomAction(transactionId id:TransactionId?, type customType:String) {
        guard shared.shouldTrack else {return}
        guard let tId  = id else {return}
        KPerformanceLoggerManager.end(logType: .custom(customType), transactionId: tId)
    }
    
    /**
     Call this method when you dont't want a log to be auto closed. This method must be called upfront after start tracking any log so that that particlar log should wait for manual closer. However if you call this method , you must call **stopTracking** so that that log will be closed.
     
     - Parameters:
        - transactionId: Transaction id against which you want to disable autocloser.
     */
    open class func makeLogWaitForCloser(transactionId id:TransactionId?) {
        guard shared.shouldTrack else {return}
        guard let tId  = id else {return}
        guard let activeLog = shared.getActiveLog(transactionId: tId) else {return}
        activeLog.waitForManualCloser()
    }
    
    /**
     Call this method when you want a log to be closed. This method is complementary to **makeLogWaitForCloser**. It should be called only when **makeLogWaitForCloser** is called upfront.
     
     - Parameters:
        - transactionId: Transaction id against which you want to close logging.
     */
    open class func stopTracking(transactionId id:TransactionId?) {
        guard shared.shouldTrack else {return}
        guard let tId  = id else {return}
        guard let activeLog = shared.getActiveLog(transactionId: tId) else {return}
        activeLog.stopTracking()
    }
}


// MARK: - KPerformanceLoggerManager Report Generation
extension KPerformanceLoggerManager {
    /**
     It is used when you want to print log report on console.
     
     - Parameters:
        - id: If provided, log report of a particular transaction id will be printed else all finished logs will be printed.
     */
    open class func consoleLogReports(_ id:TransactionId? = nil) {
        if let transactionId = id {
            KPerformanceLoggerManager.consoleSingleLogReport(id: transactionId)
        } else {
            KPerformanceLoggerManager.consoleAllLogReports()
        }
    }
    
    /**
     Call this method whenever you want to flush all finished log report to disk.
     */
    open class func flushLogReport(){
        let reportBlockOperation = BlockOperation()
        reportBlockOperation.addExecutionBlock {
            var report  =  LogFormatter.headerText
            report += shared.getReport()
            KPerformanceLoggerManager.export(report: report)
        }
        
        if let existingOperations = shared.opQueue.operations.last {
            reportBlockOperation.addDependency(existingOperations)
        }
        shared.opQueue.addOperation(reportBlockOperation)
    }
    
    fileprivate func getReport() ->String {
        var logReport = ""
        
        KPerformanceLoggerManager.shared.finishedLogs.forEach{
            logReport += $0.getFlushableReport()
        }
        return logReport
    }
    
    fileprivate class func consoleSingleLogReport(id:TransactionId) {
        let log = shared.finishedLogs.filter{$0.transactionId == id}.first
        var report  =  "\n\n"
        report += log?.prepareLogReport() ?? "--------"
        report += "\n\n"
        print(report)
    }
    
    fileprivate class func consoleAllLogReports() {
        shared.finishedLogs.forEach{
            var report  =  "\n\n"
            report += $0.prepareLogReport()
            report += "\n\n"
            print(report)
        }
    }
    
    fileprivate class func export(report: String) {
        KPLogFileManager.shared.logMessage(message: report)
//        let fileName = "Log-\(Time.current()).csv"
//        let directoryPath = FileManager.Paths.document.first
//        print("\n\n\nKPLOG \(String(describing: directoryPath))\n\n\n")
//        let path = URL(fileURLWithPath: directoryPath?.path ?? NSTemporaryDirectory()).appendingPathComponent(fileName)
//        let csvText = report
//        do {
//            try csvText.write(to: path, atomically: true, encoding: String.Encoding.utf8)
//            KPerformanceLoggerManager.cleanFinishedLogs()
//        } catch {
//            print(KPLoggerConstants.fileCreationError)
//            print("\(error)")
//        }
    }
    
    fileprivate class func cleanFinishedLogs() {
        shared.finishedLogs.removeAll()
        var activeLogcount:UInt = 0
        shared.activeLogs.forEach{
            let childCount = $0.value.childs.count
            activeLogcount += UInt(childCount)
        }
        KPLog.logCounter = activeLogcount
    }
}

// MARK: - KPerformanceLoggerManager Private Methods
extension KPerformanceLoggerManager {
    /**
     This method is called each time we want any task to start tracking. It should not be called directly as there are specific methods for which we want to track logs.
     - Parameters:
        - logInfo: Its an object containing most of the logging required upfront to track a task.
     */
    fileprivate  class func start(with logInfo:LogInfo) {
        guard shared.shouldTrack else {return}
        let tID = logInfo.transactionId
        if let activeLog = shared.getActiveLog(transactionId: tID) {
            activeLog.start(info: logInfo)
            activeLog.delegate = shared
        } else {
            let log  = KPLogger(info: logInfo)
            log.delegate = shared
            shared.activeLogs[tID] = log
        }
    }
    
    /**
     This method is called each time we want any task to stop tracking. It should not be called directly as there are specific methods for which we want to stop tracking logs.
     - Parameters:
        - type: It consists of a primitive type which should be closed. For exampele if we wnat to close a specific network tracking , we must pass network here.
        - id : Transaction id to be used for tracking events of a feature.
        - subTypeName : Any subtype apart from main primitive type. It is generally used if there are more than one primitive task that fall under same feature. For example, if there are more that one UI rendering tasks under one feature. In that case we must provide unique value for each UI subtype.
     
     */
    fileprivate  class func end(logType type:LogType, transactionId id:TransactionId,subType subTypeName:String? = nil) {
        guard shared.shouldTrack else {return}
        guard let activeLog = shared.getActiveLog(transactionId: id) else {return}
        activeLog.stop(logType: type, subType: subTypeName)
    }
    
    /**
     This method is called whenever any log has finished tracking and is ready to be move in finished logs. Here we also check whether the buffer is full and we want to offload report to disk or not.
     - Parameters:
        - log: It is an instance which constains consolidated information of all tasks under one feature track.
     */
    fileprivate  class func offloadActiveLogToFinished(log:KPLogger) {
        shared.activeLogs[log.transactionId] = nil
        shared.finishedLogs.append(log)
        if shared.finishedLogs.count >= Int(shared.flushCount){
            KPerformanceLoggerManager.flushLogReport()
        }        
    }
    

    /**
     It takes all initial information like logType,transactionId subType, etc and convert into logModel.
     - Parameters:
        - type: Contains any primitive type like UI, network etc or any custom provided type.
        - transactionId: Transaction id to be used for tracking events of a feature. It's an id which will be               unique across all the primitive types which will be tacked across a particular feature.
        - subType: Any subtype apart from main primitive type. It is generally used if there are more than one primitive task that fall under same feature. For example, if there are more that one UI rendering tasks under one feature. In that case we must provide unique value for each UI subtype.
        - size: Size of received data in bytes.
        - comment: Any comments that are to be attached for a particular type.
        - fileName: The file name to print. The default is the file where `startUI` is called.
        - lineNumber: The line number to print. The default is the line number where `startUI`
        - functionName: The line number to print. The default is name of the function from where `startUI`
     
     - Returns: **LogInfo** Model containing all initial information.
     */
    fileprivate class func getLogInfoModel(logType type:LogType,transactionId id:TransactionId, subType:String?=nil,size :String?=nil,comment:String?=nil,_ fileName: String = #file, lineNumber: UInt = #line, functionName: String = #function) -> LogInfo {
        return LogInfo(logType: type, transactionId: id,subtype:subType, size: size, comment: comment,fileName: fileName,lineNumber: lineNumber,functionName: functionName)
    }
    /**
     Call this method if you want to get refrence of any cative log againt transaction Id.
     - Parameters:
        - transactionId : Pass Transaction Id to get any active log.
     
     - Returns: Active **KPLogger** refrence.
     */
    fileprivate func getActiveLog(transactionId id:TransactionId) ->KPLogger?{
        guard let log = activeLogs[id] else {return nil}
        return log
    }
}

// MARK: - KPerformanceLoggerManager Transaction Id Management
extension KPerformanceLoggerManager {
    /**
     Call this method if to generate a unique transactio id that must be assigned to a feature and will be passes across its sub features.
    
     - Parameters:
        - identifier : Pass any identifier. It should be the name of the feature whose time we wnat to track.
     
     - Returns: Return a unique transaction Id.
     */
    open class func getLoggerTransactionIdentifier(of identifier:String) -> String?{
        guard shared.shouldTrack else {return nil}
        let tId = "\(identifier)<" + KPerformanceLoggerManager.getUniqueStamp() + ">\(KPLogger.counter)"
        KPLogger.counter += 1
        return  tId
    }
    
    fileprivate class func getUniqueStamp() -> String{
        return "\(Date().toFormat())"
    }
}


extension KPerformanceLoggerManager:KPLoggerDelegate {
    /**
     It's a callback when any current logger has finised tracking and is ready to be offloaded.
     
     - Parameters:
     - transactionId: Transaction id for which logging has been closed.
     */
    func didFinishTracking(transactionId: TransactionId?) {
        dispatchQueue.async {
            guard let tID = transactionId ,  let activeLog = self.getActiveLog(transactionId: tID) else {return}
            KPerformanceLoggerManager.offloadActiveLogToFinished(log: activeLog)
        }
    }
}

extension KPerformanceLoggerManager {
    /**
     This method will save all the finished logs which are yet to be flushed so that on next resume all last sesion finished logs will be flushed.
     */
    func saveSessionData() {
        //Moving active logs to finished logs and marking any unfinished task as unfinished.
        self.activeLogs.values.forEach{
            self.finishedLogs.append($0)
        }
        var report  =  LogFormatter.headerText
        report += KPerformanceLoggerManager.shared.getReport()
        KPLogFileManager.shared.logMessage(message: report)
        KPLogFileManager.createDeviceInfoFile()
        //KPLoggerSessionDataManager.saveSessionData(report: report)
    }
}
