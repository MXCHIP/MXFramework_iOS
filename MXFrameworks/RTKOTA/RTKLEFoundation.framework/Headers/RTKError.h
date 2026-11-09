//
//  RTKError.h
//  RTKLEFoundation
//
//  Created by jerome_gu on 2019/1/21.
//  Copyright © 2019 Realtek. All rights reserved.
//

#ifndef RTKError_h
#define RTKError_h

#import <Foundation/Foundation.h>

extern NSErrorDomain const RTKErrorDomain;

/* RTKErrorDomain Error code */
typedef enum : NSUInteger {
    RTKErrorNotAvailable = 100,
    RTKErrorTimeout,        /* generic timeout, operation is not specified. */
    RTKErrorCharacteristicNotifyEnableFail,
    RTKErrorPeripheralDisconnection,
    RTKErrorPeripheralNotConnected,
    RTKErrorUnavailable,
    RTKErrorInvalidParameter,
    
    RTKErrorATTDiscoveryFail,
    RTKErrorATTNotExist,
    RTKErrorATTDiscoveryBusy,
    RTKErrorATTDiscoveryTimeout,
    RTKErrorATTInsufficient,
    
    RTKErrorPeripheralNotOpen,
    
    RTKErrorNotConform  = 150,
} RTKErrorCode;



@interface NSError (RTKLE)

@property (readonly) BOOL isLinkloss;


/* Warn: iPhone 蓝牙开关关闭时，错误也是 Error Domain=CBErrorDomain Code=7 "The specified device has disconnected from us." UserInfo={NSLocalizedDescription=The specified device has disconnected from us. */
@property (readonly) BOOL isDisconnectByPeer;

@end


#endif /* RTKError_h */
