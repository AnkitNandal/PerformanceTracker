//
//  KPLogModels.swift
//  Ankit NandalPhoneAnkit NandalIphone
//
//  Created by Ankit Nandal on 08/02/18.
//

import Foundation
import UIKit


 struct LogInfo {
    var logType:LogType
    var subType:String?
    var transactionId:TransactionId
    var comment:String?
    var filename:String
    var lineNumber:UInt
    var functionName:String
    var dataSize:String?
    var isMainThread:Bool
    var startTime:CFTimeInterval

    init(logType type:LogType, transactionId id:TransactionId,subtype:String?=nil,size:String?=nil, comment:String?,
         fileName: String = #file, lineNumber: UInt = #line, functionName: String = #function) {
        self.logType = type
        self.transactionId = id
        self.comment = comment
        self.filename = fileName
        self.lineNumber = lineNumber
        self.functionName = functionName
        self.dataSize  = size
        self.subType = subtype
        self.isMainThread = Thread.isMainThread
        self.startTime = Time.current()
    }
}

 enum LogStatus:String{
    case started
    case success
    case fail
    case cancelled
    case timeout
}

extension LogStatus{
    public static func ==(lhs: LogStatus, rhs: LogStatus) -> Bool {
        switch (lhs, rhs) {
        case  (.started, .started),(.success, .success),(.fail, .fail),(.cancelled, .cancelled),(.timeout, .timeout):
            return true
        default:
            return false
        }
    }
}

 enum LogType{
    case userInterface
    case network
    case parsing
    case coreData
    case custom(String)
    
    var Identifier: String {
        switch self {
        case .userInterface: return "UserInterface"
        case .network: return "Network-Call"
        case .parsing: return "Parsing"
        case .coreData: return "CoreData"
        case .custom(let value): return value
        }
    }
    
    var toString: String {
        switch self {
        case .userInterface: return "userInterface"
        case .network: return "network"
        case .parsing: return "parsing"
        case .coreData: return "coreData"
        case .custom(let value): return value
        }
    }
    
}

extension LogType{
    static func ==(lhs: LogType, rhs: LogType) -> Bool {
        switch (lhs, rhs) {
        case  (.userInterface, .userInterface),(.network, .network),(.parsing, .parsing),(.coreData, .coreData):
            return true
        case let (.custom(v0), .custom(v1)):
            return v0 == v1
        default:
            return false
        }
    }
}


class Device {
    
    static var current = Device()
    var name: String
    var model: String
    var localizedModel: String
    var systemName: String
    var systemVersion: String
    
    private init() {
        self.name = UIDevice.current.name
        self.model = UIDevice.current.model
        self.localizedModel = UIDevice.current.localizedModel
        self.systemName = UIDevice.current.systemName
        self.systemVersion = UIDevice.current.systemVersion
    }
    
    var description: String{
        
      return  " Name : \(self.name) \n Model : \(self.model) \n LocalizedModel : \(self.localizedModel) \n OS : \(self.systemName) \n  OS-Version : \(self.systemVersion) \n      Model :    \(modelName)"
    }
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad6,11", "iPad6,12":                    return "iPad 5"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
        case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
        case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
        case "AppleTV5,3":                              return "Apple TV"
        case "AppleTV6,2":                              return "Apple TV 4K"
        case "AudioAccessory1,1":                       return "HomePod"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
        
    }
}


