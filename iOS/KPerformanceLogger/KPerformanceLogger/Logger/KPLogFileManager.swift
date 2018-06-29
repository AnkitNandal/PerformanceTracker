//
//  KPLogFileManager.swift
//  KP
//
//  Created by Ankit Nandal on 21/02/18.
//  Copyright © 2018 Ankit Nandal. All rights reserved.
//

import Foundation
import DDPrivate

class KPLogFileManager {
    static let shared = KPLogFileManager()
    
    var fileExtension = FileType.csv
    
    var ddLogger:DDFileLogger?
    
    var logFilePaths:[String]? {
        return getLogFilesPath()
    }
        
    
    
    lazy var defaultFileInfo:(name:String,directory:String,frequency:TimeInterval,size:UInt64) = {
        let fileName = shared.getUniqueFileName(with: "KPLOG||")
        var libraryPath = FileManager.Paths.library.first!
        libraryPath.appendPathComponent("KPLogs")
        try? FileManager.default.createDirectory(at: libraryPath, withIntermediateDirectories: true, attributes: nil)
        let directoryName = libraryPath.path
        let rollingFrequency:TimeInterval = 60*60*24
        let maximumFileSize:UInt64 = 100*1024
        return(fileName,directoryName,rollingFrequency,maximumFileSize)
    }()
    
    private init() {}
    
    
    func config(fileName name:String?,directoryPath path:String?, requiredFileSize size:UInt64?,rollingFrequency frequency:TimeInterval?){
        var filename = defaultFileInfo.name
        if let customFileName = name {
            filename =  getUniqueFileName(with: customFileName)
        }
        let directoryPath = path ?? defaultFileInfo.directory
        let frequency = frequency ?? defaultFileInfo.frequency
        let maxFileSize = size ?? defaultFileInfo.size
        let logFileManager = KPDDFileLogManager(directory: directoryPath, fileName: filename)
        ddLogger = DDFileLogger(logFileManager: logFileManager)
        ddLogger?.rollingFrequency = frequency
        ddLogger?.maximumFileSize = maxFileSize
        DDLog.add(ddLogger)
    }
    
    func logMessage(message:String) {
        let logMessage = DDLogMessage(message: message, level: .all, flag: .debug, context: 0  , file: #file, function: #function, line: #line, tag: nil, options: [.copyFile, .copyFunction], timestamp: nil)
        ddLogger?.log(message: logMessage)
    }
    
    fileprivate func getUniqueFileName(with name:String) -> String {
        return "\(name)\(Date().toFormat()).\(self.fileExtension)".replacingOccurrences(of: "/", with: "_")
    }
    
    fileprivate func getLogFilesPath() -> [String]?{
         guard let filePaths = ddLogger?.logFileManager.sortedLogFilePaths else {return nil}
        return filePaths
    }
    
    static func createDeviceInfoFile() {
        let path = shared.defaultFileInfo.directory
        let infoFilePath = URL(fileURLWithPath: path).appendingPathComponent("DeviceInfo.txt")

        let data = Device.current.description + "\n\n" + (KPLoggerConfiguration.shared.info ?? "")
        do {
            try data.write(to: infoFilePath, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print(KPLoggerConstants.fileCreationError)
            print("\(error)")
        }
    }

}

class KPDDFileLogManager:DDLogFileManagerDefault{
    var name:String
    
    override var newLogFileName: String {
        return name
    }
    
    init(directory:String,fileName:String) {
        name = fileName
        super.init(logsDirectory: directory)
    }
}

enum FileType:String{
    case csv
    case txt
}
