//
//  KPLoggerConstants.swift
//  Ankit NandalPhoneAnkit NandalIphone
//
//  Created by Ankit Nandal on 07/03/18.
//

import Foundation


enum KPLoggerConstants {
    static var sessionFile = "KPLoggerSessionDataManager.bat"
    static var logDateFormat = "MM_dd_yyyy_HH_mm_ss.SSS"
    static var fileCreationError = "Failed to create file"
    
    
    static var plistFile = "LoggerBenchmark"
    static var plistFileExtension = "plist"
    static var plistFileError = "LoggerBenchmark.plist file is missing!!!"
    static var plistFileDecodingError = "LoggerBenchmark.plist file is not decoded properly. Please check whether file has garbage data."
    static var perfromanceLoggerQueue = "kPerformanceLoggerQueue"
    static var appTerminationNotification = NSNotification.Name.UIApplicationWillTerminate
}
