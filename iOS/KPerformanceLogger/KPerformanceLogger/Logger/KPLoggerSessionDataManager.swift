////
////  KPLoggerSessionDataManager.swift
////  Ankit NandalPhoneAnkit NandalIphone
////
////  Created by Ankit Nandal on 06/03/18.
////
//
//import Foundation
//import UIKit
//
//
//class KPLoggerSessionDataManager {
//    
//    /**
//     This will save all the finished logs report which are yet to be flued on disk. it will persist log report so that on resume we can use last ession report.
//     
//        - Parameters:
//            - report : Report to save.
//     */
//    static func saveSessionData(report:String) {
//        if report.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {return}
//        let dictionary:KPLoggerSessionData = KPLoggerSessionData(counter: KPLog.logCounter, report: report)
//        var filePath = FileManager.Paths.document.first!
//        filePath = filePath.appendingPathComponent(KPLoggerConstants.sessionFile)
//        let encodedData = try? JSONEncoder().encode(dictionary)
//        do {
//            try encodedData?.write(to: filePath)
//        } catch {
//            
//        }
//    }
//    
//    /**
//     Retreive last session data.
//     
//     - Returns: KPLoggerSessionData.
//     */
//    static func getLastSessionData() ->KPLoggerSessionData?{
//        
//        let filePath = FileManager.Paths.document.first!.appendingPathComponent(KPLoggerConstants.sessionFile)
//        
//        if let data = try? Data(contentsOf: filePath) {
//            if let report = try? JSONDecoder().decode(KPLoggerSessionData.self, from: data) {
//                KPLoggerSessionDataManager.removeLastSessionData()
//                return report
//            }
//        }
//        return nil
//    }
//   
//    static func removeLastSessionData(){
//        let filePath = FileManager.Paths.document.first!.appendingPathComponent(KPLoggerConstants.sessionFile)
//       _ =  try? FileManager.default.removeItem(at: filePath)
//    }
//}
//
///**
// Contains log session data information.
//*/
//struct KPLoggerSessionData:Codable {
//    var counter:UInt
//    var report:String
//}
