//
//  RTKLELogMacros.h
//  RTKLEFoundation
//
//  Created by jerome_gu on 2019/1/8.
//  Copyright © 2019 Realtek. All rights reserved.
//

#ifndef RTKLELogMacros_h
#define RTKLELogMacros_h

#ifndef RTK_EXPORT_AS_STATIC_LIBRARY
#import "RTKLog.h"

#define RTKLogError(fmt, ...)   [RTKLog _logWithLevel:RTKLogLevelError format: (fmt), ## __VA_ARGS__]
#define RTKLogWarn(fmt, ...)    [RTKLog _logWithLevel:RTKLogLevelWarning format: (fmt), ## __VA_ARGS__]
#define RTKLogInfo(fmt, ...)    [RTKLog _logWithLevel:RTKLogLevelInfo format: (fmt), ## __VA_ARGS__]
#define RTKLogDebug(fmt, ...)   [RTKLog _logWithLevel:RTKLogLevelDebug format: (fmt), ## __VA_ARGS__]
#define RTKLogVerbose(fmt, ...) [RTKLog _logWithLevel:RTKLogLevelVerbose format: (fmt), ## __VA_ARGS__]

#else

#define RTKLogError(fmt, ...)   NSLog((fmt), ## __VA_ARGS__)
#define RTKLogWarn(fmt, ...)    NSLog((fmt), ## __VA_ARGS__)
#define RTKLogInfo(fmt, ...)    NSLog((fmt), ## __VA_ARGS__)
#define RTKLogDebug(fmt, ...)   NSLog((fmt), ## __VA_ARGS__)
#define RTKLogVerbose(fmt, ...) NSLog((fmt), ## __VA_ARGS__)

#endif


#endif /* RTKLELogMacros_h */
