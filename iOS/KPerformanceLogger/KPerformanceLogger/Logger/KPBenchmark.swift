//
//  KKPBenchmark.swift
//  KPerformanceLogger
//
//  Created by Ankit Nandal on 05/02/18.
//  Copyright © 2018 Ankit Nandal. All rights reserved.
//

import Foundation
import UIKit


class KPBenchmark{
    static var shared = KPBenchmark()
    var types:BenchmarksInfo = []
    
    private init(){
        
        guard let plistPath = Bundle(for: type(of: self)).path(forResource: KPLoggerConstants.plistFile, ofType: KPLoggerConstants.plistFileExtension) else {
            assert(false, KPLoggerConstants.plistFileError)
            return
        }
        guard let plistData = FileManager.default.contents(atPath: plistPath) else { return }
        do {
            if let plist = try PropertyListSerialization.propertyList(from: plistData, options: .mutableContainers, format: nil) as? Array<Dictionary<String,Any>> {
                self.types = BenchMarkInfo.getBenchmarks(info: plist)
            }

        } catch {
            assert(false, KPLoggerConstants.plistFileDecodingError)
            print("Error\(error.localizedDescription)")
        }
    }
}

extension KPBenchmark{
    func setBenchmark(with info:BenchMarkInfo) {
        types.append(info)
    }
}


extension KPBenchmark {

    static var uiBenchmarkTime = getFlatBenchmarkTime(type: .userInterface)
    static var networkBenchmarkTime = getFlatBenchmarkTime(type: .network)
    static var coreDataBenchmarkTime = getFlatBenchmarkTime(type: .coreData)
    static var parsingBenchmarkInfo = getParsingBenchmarkTime(type: .parsing)
    
    static func didOperationPassedBenchmarking(from type :LogType,time elapsed: ElapsedTime,size:Double?=0.0) -> Bool{
        func getSuccessStatusFromCustomData() -> Bool{
            let benchmarkType =  shared.types.filter{$0.type == type.toString}.first
            guard let bTime = benchmarkType?.benchmarkTime else {return false}
            if let dataSize = size {
                guard let bSize = benchmarkType?.data else {return false}
                let expectedTime = (dataSize/bSize) * bTime
                return KPBenchmark.getStatus(expected: expectedTime, took: elapsed)
            } else  {
                return KPBenchmark.getStatus(expected: bTime, took: elapsed)
            }
        }
        
        if type == .custom(type.toString){
            return getSuccessStatusFromCustomData()
        } else {
            switch type {
            case .userInterface:
                return KPBenchmark.getStatus(expected: KPBenchmark.uiBenchmarkTime, took: elapsed)
            case .coreData:
                return KPBenchmark.getStatus(expected: KPBenchmark.coreDataBenchmarkTime, took: elapsed)
            case .network:
                return KPBenchmark.getStatus(expected: KPBenchmark.networkBenchmarkTime, took: elapsed)
            case .parsing:
                if let dataSize = size {
                    let parsingData = KPBenchmark.parsingBenchmarkInfo
                    let expectedTime = (dataSize/parsingData.size) * parsingData.time
                    return KPBenchmark.getStatus(expected: expectedTime, took: elapsed)
                }
                return false
            default:
                return KPBenchmark.getStatus(expected: KPBenchmark.networkBenchmarkTime, took: elapsed)
            }
        }
    }
    
    private static func getStatus(expected:Double,took:Double)-> Bool{
        return expected >= took
    }
    
    private static func getFlatBenchmarkTime(type :LogType) -> Double{
        let benchmarkType =  shared.types.filter{$0.type == type.toString}.first
        guard let bm = benchmarkType else {return 0.0}
        print(bm.benchmarkTime)
        return bm.benchmarkTime
    }
    private static func getParsingBenchmarkTime(type :LogType) -> (time:Double,size:Double){
        let benchmarkType =  shared.types.filter{$0.type == type.toString}.first
        guard let bmTime = benchmarkType?.benchmarkTime, let size = benchmarkType?.data else {return (0,0)}
        return (bmTime,size)
    }
}

typealias BenchmarksInfo = [BenchMarkInfo]

struct BenchMarkInfo {
    var type:String
    var benchmarkTime:Double
    var data:Double?
    
    
    init(dict:[String:Any?]) {
        self.type = dict["type"] as? String ?? ""
        self.benchmarkTime = dict["benchmarkTime"] as? Double ?? 0
        self.data = dict["data"] as? Double

    }
    
    static func getBenchmarks(info:Array<Dictionary<String,Any>>) -> BenchmarksInfo{
        var benchmarks:BenchmarksInfo = []
        info.forEach {
            benchmarks.append(BenchMarkInfo(dict: $0))
        }
        return benchmarks
    }
}
