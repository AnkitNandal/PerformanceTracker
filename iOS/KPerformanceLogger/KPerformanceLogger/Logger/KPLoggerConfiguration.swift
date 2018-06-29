//
//  KPerformanceLoggerConfiguration
//  KPerformanceLogger
//
//  Created by Ankit Nandal on 03/01/18.
//  Copyright © 2018 Ankit Nandal. All rights reserved.
//

import Foundation
import UIKit

//@objcMembers
/**
 This class will be responsible for all the configutration related to Performance Logger.
 */
open class KPLoggerConfiguration :NSObject{
    /**
     Shared instance of Performance Logger Configurations.
    */
    open static var shared: KPLoggerConfiguration = {
        return KPLoggerConfiguration()
    }()
   
    /**
     Provide a time in seconds after which any unfinished log will automatically be closed.
     Defaults is 30 seconds.
     */
     open var autoCloserTime:TimeInterval = 30
    
    /**
     Whether to track all logs or not. If true Performance Logger will track all the logs else it will come in disabled state.
     */
    open var enable: Bool = false
    
    /**
     A value that will determine after how much log records should it flush report to persistance storage.
     */
    open var fulshCount: UInt = 100
    
    /**
     An array of files where all the log reports have been saved.
     */
    open var logsPath: [String]? {
        return KPLogFileManager.shared.logFilePaths
    }
    
    /**
     Any specific information that you want to provide like hostname you are referring to, environment you are using ,etc.
     */
    open var info:String?
    
    // MARK: - Class Initilizer
    override private init() {}
    
    /**
     It is used to configure default Performance Logger configurations. For any custom configurations refer 'configLogGeneration'
     
     - Parameters:
        - enable: A configuration item which will tell whether Performance Logger should track all the logs. If its true all the logs will be tracked, if false all the logs will stop tracking and Performance Logger will come into dormant state unless its true.
        - flushCount: A count which will decide when all the finished logs reports should be saved to persistant storage.By defaults the flush count is 100.
     */
    open class func useDefaultConfiguration() {
        KPLoggerConfiguration.shared.configureReportGeneration(enable: true, flushCount: KPLoggerConfiguration.shared.fulshCount)
    }
    
    /**
     Create your own custom benchmark by providing required information.
     
     - Parameters:
     - type: Name of the custom bench mark. It shoud not be one of the primitive ttypes that are declared already.
     - benchmarkTime: A time which will be considered whether  a feature passed its respective benchmarking.
     - dataSize: Its an optional field which should be provided if the custom benchmarking will be calculated in the basis of data size as  well.
     */
    open class func setCustomBenchmark(type name:String,benchmarkTime time:Double, dataSize size:Double=0) {
        var dataSize:Double?
        if size != 0 {
           dataSize = size
        }
        let dict = ["type":name,"benchmarkTime":time,"data":dataSize] as [String : Any?]
        let newCustomBenchmark = BenchMarkInfo(dict: dict)
        KPBenchmark.shared.setBenchmark(with: newCustomBenchmark)
    }
    
    /**
     It is used if you want to provide any custom report generation information to manage howthe log will be generated
     
     
     - Parameters:
        - enable: A configuration item which will tell whether Performance Logger should track all the logs. If its true all the logs will be tracked, if false all the logs will stop tracking and Performance Logger will come into dormant state unless its true.
        - flushCount: A count which will decide when all the finished logs reports should be saved to persistant storage.
        - fileName: Name of the custom bench mark. It shoud not be one of the primitive ttypes that are declared already.
        - directoryPath: A time which will be considered whether  a feature passed its respective benchmarking.
        - maximumFileSizeInBytes: Its an optional field which should be provided if the custom benchmarking will be calculated in the basis of data size as  well.
        - rollingFrequency: Its an optional field which should be provided if the custom benchmarking will be calculated in the basis of data size as  well.
        - maximumFileSizeInBytes: Its an optional field which should be provided if the custom benchmarking will be calculated in the basis of data size as  well.
     */
    open class func customLogGenerationConfigurations(_ enable:Bool,flushCount:UInt,fileName name:String?=nil,directoryPath path:String?=nil, maximumFileSizeInBytes size:UInt64=0, rollingFrequency frequency:TimeInterval=0) {
        var timeInterval:TimeInterval?
        if frequency != 0 {
            timeInterval = frequency
        }
        var fileSize:UInt64?
        if size != 0 {
            fileSize = size
        }
        KPLoggerConfiguration.shared.configureReportGeneration(enable: enable, flushCount: flushCount, fileName: name, directoryPath: path, maximumFileSizeInBytes: fileSize, rollingFrequency: timeInterval)
    }
    
    
    /**
     Initiate configurations of Performance Logger.
     
     
     - Parameters:
        - enable: A configuration item which will tell whether Performance Logger should track all the logs. If its true all the logs will be tracked, if false all the logs will stop tracking and Performance Logger will come into dormant state unless its true.
        - flushCount: A count which will decide when all the finished logs reports should be saved to persistant storage.
        - fileName: Name of the custom bench mark. It shoud not be one of the primitive ttypes that are declared already.
        - directoryPath: A time which will be considered whether  a feature passed its respective benchmarking.
        - maximumFileSizeInBytes: Its an optional field which should be provided if the custom benchmarking will be calculated in the basis of data size as  well.
        - rollingFrequency: Its an optional field which should be provided if the custom benchmarking will be calculated in the basis of data size as  well.
        - maximumFileSizeInBytes: Its an optional field which should be provided if the custom benchmarking will be calculated in the basis of data size as  well.
     */
    private func configureReportGeneration(enable:Bool,flushCount:UInt,fileName name:String?=nil,directoryPath path:String?=nil, maximumFileSizeInBytes size:UInt64?=nil, rollingFrequency frequency:TimeInterval?=nil) {
        KPLoggerConfiguration.shared.enable = enable
        KPLoggerConfiguration.shared.fulshCount = flushCount
        KPLogFileManager.shared.config(fileName: name, directoryPath: path, requiredFileSize: size, rollingFrequency: frequency)
    }
}


