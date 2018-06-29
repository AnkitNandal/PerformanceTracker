//
//  KPLogExtensions.swift
//  Ankit NandalPhoneAnkit NandalIphone
//
//  Created by Ankit Nandal on 08/02/18.
//

import Foundation

public typealias ElapsedTime = Double
public typealias TransactionId = String
public typealias LogTypeTransactionId = TransactionId
public typealias LogReport = String


//Associating Logger Id to NSObject
private var AssociatedObjectHandleForloggerTransaction: UInt8 = 0
private var AssociatedObjectHandleForloggerCustomTypeId: UInt8 = 0
private var AssociatedObjectHandleForloggerComment: UInt8 = 0

public extension NSObject {
    /**
     Transaction id is used for tracking events of a feature. It's an id which will be unique across all the primitive types which will be tacked across a particular feature. It will remian same for a particular instance of a feature and must be passed to other instances which are instantiated as a part of main fetaure.
     */
    var kpLoggerTransactionId:TransactionId? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectHandleForloggerTransaction) as? TransactionId
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectHandleForloggerTransaction, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /**
     A sub transaction id apart from main transaction id. It is generally created and used if there are more than one primitive task that fall under same feature. For example, if there are more that one Network tasks or Network calls are triggered multiple times under a same fetaure. In that case we must provide unique value for each network calls.
     */
    var kploggerCustomTransactionId:TransactionId? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectHandleForloggerCustomTypeId) as? TransactionId
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectHandleForloggerCustomTypeId, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    /**
     Any commant that we want to attach to any instance.
     */
    var kploggerComments:String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectHandleForloggerComment) as? TransactionId
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectHandleForloggerComment, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}



extension FileManager {
    enum Paths{
        static var document = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)
        static var library = FileManager.default.urls(for: .libraryDirectory, in: .allDomainsMask)
    }
}


extension Date {
    func toFormat(dateFormat: String = KPLoggerConstants.logDateFormat)-> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: self)
    }
}

public extension Data {
    func sizeString(units: ByteCountFormatter.Units = [.useAll], countStyle: ByteCountFormatter.CountStyle = .file) -> String {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = units
        bcf.countStyle = .file
        return bcf.string(fromByteCount: Int64(count))
    }
}

