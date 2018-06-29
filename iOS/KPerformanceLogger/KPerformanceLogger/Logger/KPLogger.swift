//
//  KPLogger
//
//
//  Created by Ankit Nandal on 29/01/18.
//  Copyright © 2018 Ankit Nandal. All rights reserved.
//

import Foundation
protocol KPLoggerDelegate :class{
    /**
     It gives a callback when current logger has finised tracking and is ready to be offloaded.
     
     - Parameters:
        - transactionId: Transaction id to be used for tracking events of a feature. It's an id which will be unique across all the primitive types which will be tacked across a particular feature.
     */
    func didFinishTracking(transactionId:TransactionId?)
}

class KPLogger{
    /**
     A counter which tells how many KPLogger has been instantiated.
     */
    static var counter = 0
    
    /**
      Unique Transaction id for any log record.
     */
    var transactionId:TransactionId
    
    /**
     Status of the record whether it started, cancelled,etc.
     */
    var status:LogStatus?
    
    /**
     It keeps any comment that we want to keep across any record.
     */
    var comments:String?
    
    /**
     It holds all the subtasks that belong to a particular feature.
     */
    var childs:Dictionary<TransactionId,KPLog> = [:]
    
    /**
     A queue that offloads tasks from main thread.
     */
    var dispatchQueue:DispatchQueue!
    
    /**
     A queue to handle auto closer state of log.
     */
    var autoCloserDispatchQueue:DispatchQueue!
    
    /**
     A work item that executes auto closer.
     */
    var autoCloserDispatchItem:DispatchWorkItem?
    
    /**
     A flag to indicated whether log has finished tracking.
     */
    var finishedTracking:Bool
    
    /**
     Delegate that let performance logger know when log has finished.
     */
    weak var delegate:KPLoggerDelegate?

    /**
     Whether a log should override autocloser and wait for manual closer.
     */
    var shouldWaitForCloser:Bool {
        willSet{
            if newValue{
              invalidateAutoCloser()
            }
        }
    }
    /**
     Initilize a log record for a particular feature with proper info.
     
     - Parameters:
        - info : Loginfo model containing all the initial informations required to start tracking a log.
     */
    init(info:LogInfo) {
        finishedTracking = false
        shouldWaitForCloser = false
        dispatchQueue = DispatchQueue(label: "kplogger")
        autoCloserDispatchQueue = DispatchQueue(label: "kploggerAutoCloser")
        self.transactionId = info.transactionId
        self.start(info:info)
    }
    
    deinit {
//        print("KPLogger Deinit :\(self.transactionId)")
    }
}


extension KPLogger {
    /**
     Start tracking a task under a log feature.
     
     - Parameters:
        - info : Loginfo model containing all the initial informations required to start tracking a log.
     */
    func start(info:LogInfo) {
        dispatchQueue.async {
            let childID = KPLogger.ChildId.from(transactionId: info.transactionId, logType: info.logType,subType: info.subType).getId
            let childTracker = KPLog(logInfo:info)
            self.childs[childID] = childTracker
            self.maintainAutoCloserState()
        }
    }
    
    /**
     Logger should cancel auto closer and wait for manual close.
     */
    func waitForManualCloser() {
        self.shouldWaitForCloser = true
    }
    
    /**
     Prepare a console printable log report.
     */
    func prepareLogReport() -> LogReport{
        var report = "\(transactionId)\n\n"
        self.childs.forEach{report += "\($0.value.type.Identifier)\n\($0.value.report)\n\n"}
        return report
    }
    
    /**
     Prepares and return a final log report with proper format to be writable on file.
     */
    func getFlushableReport() -> LogReport{
        var report = ""
        self.childs.forEach{
            report += "\($0.value.report)"
        }
        return report
    }
}


extension KPLogger {
    /**
     Logger will close tracking all tasks immediately.
     */
    func stopTracking() {
        self.shouldWaitForCloser = false
        offload()
    }
    
    /**
     Stop tracking a task under a log feature.
     
     - Parameters:
        - type : Particular type of task.
        - subTypeName : Any subtype apart from main primitive type. It is generally used if there are more than one primitive task that fall under same feature. For example, if there are more that one UI rendering tasks under one feature. In that case we must provide unique value for each UI subtype.

     */
    func stop (logType type:LogType,subType subTypeName:String? = nil) {
        dispatchQueue.async {
        guard let child = getChild(from: type, subtype: subTypeName) else {return}
        child.stopTimeTracking()
        
        if shouldWaitForCloser {
            return
        }
      }
    }
    
    
    /**
     It will maintain auto closer state of a log.
     */
    fileprivate  func maintainAutoCloserState() {
        if finishedTracking || shouldWaitForCloser{return}
        
        invalidateAutoCloser()
        
        autoCloserDispatchItem = DispatchWorkItem{ [weak self] in
            if self?.finishedTracking == true {return}
            self?.offload()
        }
        
        let autoCloserTime =  DispatchTime.now() + KPLoggerConfiguration.shared.autoCloserTime
        autoCloserDispatchQueue.asyncAfter(deadline: autoCloserTime, execute: autoCloserDispatchItem!)
        
    }
    
    fileprivate func invalidateAutoCloser() {
        autoCloserDispatchItem?.cancel()
    }
    
    /**
     It will tell whether all logs has finished tracking.
     */
    private var allLogsFinishedTracking: Bool {
        return childs.filter{$0.value.finished == true}.count == childs.count
    }
    
    /**
     All tasks under a log  has been finished and are ready to be offloaded. When this method is called log will stop further tracking and is ready to be pushed on statistics file.
     */
    private func offload(status:LogStatus = .success) {
        invalidateAutoCloser()
        finishedTracking = true
        self.status = status
        delegate?.didFinishTracking(transactionId: transactionId)
    }
}

extension KPLogger {
    /**
    Get a particulat child based.
    
     - Parameters:
        - logType : Particular type of task.
        - subtype : Any subtype apart from main primitive type. It is generally used if there are more than one primitive task that fall under same feature. For example, if there are more that one UI rendering tasks under one feature. In that case we must provide unique value for each UI subtype.
     - Returns: An instance of active KPLog.
     */
    fileprivate func getChild(from logType:LogType,subtype:String?=nil) ->KPLog?{
        let childID = KPLogger.ChildId.from(transactionId: self.transactionId, logType: logType, subType: subtype).getId
        guard let tracker = childs[childID] else {return nil}
        return tracker
    }
    
    /**
     It will create a unique child ids for tasks under a particular feature.
     */
    fileprivate enum ChildId{
        case from(transactionId:TransactionId,logType:LogType,subType:String?)
        var getId:LogTypeTransactionId {
            switch self {
            case .from(let id, let type,let subType):
                var childLogId = id+"<"+type.Identifier+">"
                if let customSubType = subType {
                    childLogId += "<"+customSubType+">"
                }
                return childLogId
            }
        }
    }
}


