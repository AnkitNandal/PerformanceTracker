//
//  KPLogManager.h
//  KohlsPhoneKohlsIphone
//
//  Created by Ankit Nandal on 09/02/18.
//


#ifndef KPLogManager_h
#define KPLogManager_h

/**
 It generate a unique transaction id that must be assigned to a feature and will be passes across its sub features.
 - Returns: Returns a unique transaction Id.
 */
#define KPLogTransactionID(logName) [KPerformanceLoggerManager getLoggerTransactionIdentifierOf:logName];;

/**
 Call this macro when you dont't want a log to be auto closed. This macro must be called upfront after start tracking any log so that that particlar log should wait for manual closer. However if you call this macro , you must call **stopTracking** so that that log will be closed.
 
 - Parameters:
 - transactionId: Transaction id against which you want to disable autocloser.
 */
#define KPLogMakeWaitForCloser(transactionId) [KPerformanceLoggerManager makeLogWaitForCloserWithTransactionId:transactionId];

/**
 Call this macro when you want a log to be closed. If you don't call this method log will automatically be closed after a default autocloser time. It must be called when **makeLogWaitForCloser** is called upfront.
 
 - Parameters:
 - transactionId: Transaction id against which you want to close logging.
 */
#define KPLogStopTracking(transactionId)  [KPerformanceLoggerManager stopTrackingWithTransactionId:transactionId];

/**
 Start tracking for a UI rendering task.
 
 - Parameters:
 - transactionId: Transaction id to be used for tracking events of a feature. It's an id which will be               unique across all the primitive types which will be tacked across a particular feature.
 - comment: Any comments that are to be attached for a particular type.
 */
#define KPLogStartUI(transactionId,comments) KPLogStartCascadeUI(transactionId,nil,comments)

/**
 Call this method whenever you want to stop tracking an ongoing UI task.
 
 - Parameters:
 - transactionId: Transaction id to be used for tracking events of a feature. It's an id which will be               unique across all the primitive types which will be tacked across a particular feature.
 */
#define KPLogStopUI(transactionId) KPLogStopCascadeUI(transactionId,nil)

/**
 Start tracking for a UI rendering task. Here we wust pass a unique subtype so that thsi UI task will be considered as a seperate tracking.
 
 - Parameters:
 - transactionId: Transaction id to be used for tracking events of a feature. It's an id which will be               unique across all the primitive types which will be tacked across a particular feature.
 - subType: Any subtype apart from main primitive type. It is generally created and used if there are more than one primitive task that fall under same feature. For example, if there are more that one Network tasks or Network calls are triggered multiple times under a same fetaure. In that case we must provide unique value for each network calls.
 - comment: Any comments that are to be attached for a particular type.
 */
#define KPLogStartCascadeUI(transactionId,subTypeName,comments) [KPerformanceLoggerManager startUIWithTransactionId:transactionId subType:subTypeName comment:comments fileName:NSStringFromClass([self class]) lineNumber:__LINE__ functionName:NSStringFromSelector(_cmd)];

/**
 Call this method whenever you want to stop tracking an ongoing UI task. Here we wust pass a unique subtype so that thsi UI task will be considered as a seperate tracking.
 
 - Parameters:
 - transactionId: Transaction id to be used for tracking events of a feature. It's an id which will be               unique across all the primitive types which will be tacked across a particular feature.
 - subType: Any subtype apart from main primitive type. It is generally created and used if there are more than one primitive task that fall under same feature. For example, if there are more that one UI tasks under a same fetaure. In that case we must provide unique value for each UI tasks.
 */
#define KPLogStopCascadeUI(transactionId,subTypeName) [KPerformanceLoggerManager stopUIWithTransactionId:transactionId subType:subTypeName];

/**
 Start tracking for a Network task.
 
 - Parameters:
 - transactionId: Transaction id to be used for tracking events of a feature. It's an id which will be               unique across all the primitive types which will be tacked across a particular feature.
 - subType: Any subtype apart from main primitive type. It is generally created and used if there are more than one primitive task that fall under same feature. For example, if there are more that one Network tasks or Network calls are triggered multiple times under a same fetaure. In that case we must provide unique value for each network calls.
 */
#define KPLogStartNetwork(transactionId, subTypeName) [KPerformanceLoggerManager startNetworkWithTransactionId:transactionId subType:subTypeName comment:nil fileName:NSStringFromClass([self class]) lineNumber:__LINE__ functionName:NSStringFromSelector(_cmd)];

/**
 Start tracking for a Network task with comments.
 
 - Parameters:
 - transactionId: Transaction id to be used for tracking events of a feature. It's an id which will be               unique across all the primitive types which will be tacked across a particular feature.
 - subType: Any subtype apart from main primitive type. It is generally created and used if there are more than one primitive task that fall under same feature. For example, if there are more that one Network tasks or Network calls are triggered multiple times under a same fetaure. In that case we must provide unique value for each network calls.
 - comment: Any comments that are to be attached for a particular type.
 - fileName: The file name to print. The default is the file where `startUI` is called.
 - lineNumber: The line number to print. The default is the line number where `startUI`
 - functionName: The line number to print. The default is name of the function from where `startUI`
 is called.
 */
#define KPLogStartNetworkWithComments(transactionId, subTypeName,comments) [KPerformanceLoggerManager startNetworkWithTransactionId:transactionId subType:subTypeName comment:comments fileName:NSStringFromClass([self class]) lineNumber:__LINE__ functionName:NSStringFromSelector(_cmd)];

/**
 Call this macro whenever you want to stop tracking an ongoing n/w task.
 
 - Parameters:
 - transactionId: Transaction id to be used for tracking events of a feature. It's an id which will be               unique across all the primitive types which will be tacked across a particular feature.
 - subType: Any subtype apart from main primitive type. It is generally created and used if there are more than one primitive task that fall under same feature. For example, if there are more that one Network tasks or Network calls are triggered multiple times under a same fetaure. In that case we must provide unique value for each network calls.
 */
#define KPLogStopNetwork(transactionId,subTypeName) [KPerformanceLoggerManager stopNetworkWithTransactionId:transactionId subType:subTypeName];

/**
 Start tracking for a Network response Parsing task.
 
 - Parameters:
 - transactionId: Transaction id to be used for tracking events of a feature. It's an id which will be               unique across all the primitive types which will be tacked across a particular feature.
 - subType: Any subtype apart from main primitive type. It is generally created and used if there are more than one primitive task that fall under same feature. For example, if there are more that one Network tasks or Network calls are triggered multiple times under a same fetaure. In that case we must provide unique value for each network calls.
 - dataSize: Size of received data in bytes.
 - comments: Any comments that are to be attached for a particular type.
 */
#define KPLogStartParsing(transactionId,subTypeName, dataSize,comments) [KPerformanceLoggerManager startParsingWithTransactionId:transactionId subType:subTypeName size:dataSize comment:comments  fileName:NSStringFromClass([self class]) lineNumber:__LINE__ functionName:NSStringFromSelector(_cmd)];

/**
 Call this macro whenever you want to stop tracking an ongoing network response Parsing task.
 
 - Parameters:
 - transactionId: Transaction id to be used for tracking events of a feature. It's an id which will be               unique across all the primitive types which will be tacked across a particular feature.
 - subType: Any subtype apart from main primitive type. It is generally created and used if there are more than one primitive task that fall under same feature. For example, if there are more that one Network tasks or Network calls are triggered multiple times under a same fetaure. In that case we must provide unique value for each network calls.
 */
#define KPLogStopParsing(transactionId,subTypeName) [KPerformanceLoggerManager stopParsingWithTransactionId:transactionId subType:subTypeName];

/**
 Start tracking for a CoreData task.
 
 - Parameters:
 - transactionId: Transaction id to be used for tracking events of a feature. It's an id which will be               unique across all the primitive types which will be tacked across a particular feature.
 - comment: Any comments that are to be attached for a particular type.
 */
#define KPLogStartCoreData(transactionId, comments) KPLogStartCascadeCoreData(transactionId,nil,comments);

/**
 Call this macro whenever you want to stop tracking an ongoing CoreData task.
 
 - Parameters:
 - transactionId: Transaction id to be used for tracking events of a feature. It's an id which will be               unique across all the primitive types which will be tacked across a particular feature.
 */
#define KPLogStopCoreData(transactionId) KPLogStopCascadeCoreData(transactionId,nil);

/**
 Start tracking for a CoreData task.
 
 - Parameters:
 - transactionId: Transaction id to be used for tracking events of a feature. It's an id which will be               unique across all the primitive types which will be tacked across a particular feature.
 - subType: Any subtype apart from main primitive type. It is generally created and used if there are more than one primitive task that fall under same feature. For example, if there are more that one Network tasks or Network calls are triggered multiple times under a same fetaure. In that case we must provide unique value for each network calls.
 - comment: Any comments that are to be attached for a particular type.
 */
#define KPLogStartCascadeCoreData(transactionId, subTypeName,comments) [KPerformanceLoggerManager startCoreDataWithTransactionId:transactionId subType:subTypeName comment:comments fileName:NSStringFromClass([self class]) lineNumber:__LINE__ functionName:NSStringFromSelector(_cmd)];

/**
 Call this macro whenever you want to stop tracking an ongoing CoreData task.
 
 - Parameters:
 - transactionId: Transaction id to be used for tracking events of a feature. It's an id which will be               unique across all the primitive types which will be tacked across a particular feature.
 - subType: Any subtype apart from main primitive type. It is generally created and used if there are more than one primitive task that fall under same feature. For example, if there are more that one Network tasks or Network calls are triggered multiple times under a same fetaure. In that case we must provide unique value for each network calls.
 */
#define KPLogStopCascadeCoreData(transactionId,subTypeName) [KPerformanceLoggerManager stopCoreDataWithTransactionId:transactionId subType:subTypeName];

/**
 Start tracking any custom action that is not available primitively. Here we can start tracking any custom task that we wnat to. For example , there may be a View Model creator task that we are doiung before populating data. So in this case we must pass a custom type along with transaction Id.
 
 - Parameters:
 - transactionId: Transaction id to be used for tracking events of a feature. It's an id which will be               unique across all the primitive types which will be tacked across a particular feature.
 - customTypeName: Any custom subtype apart from main primitive type. It shoud be unique to clearly mention specific custom task.
 - comment: Any comments that are to be attached for a particular type.
 */
#define KPLogStartCustomAction(transactionId,customTypeName,comments) [KPerformanceLoggerManager startCustomActionWithTransactionId:transactionId type:customTypeName comment:comments fileName:NSStringFromClass([self class]) lineNumber:__LINE__ functionName:NSStringFromSelector(_cmd)]

/**
 Call this method whenever you want to stop tracking an ongoing custom task.
 
 - Parameters:
 - transactionId: Transaction id to be used for tracking events of a feature. It's an id which will be               unique across all the primitive types which will be tacked across a particular feature.
 - customType: Any custom subtype apart from main primitive type. It shoud be unique to clearly mention specific custom task.
 */
#define KPLogStopCustomAction(transactionId,customType) [KPerformanceLoggerManager stopCustomActionWithTransactionId:transactionId type:customType];

#endif

