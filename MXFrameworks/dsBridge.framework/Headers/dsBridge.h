//
//  dsBridge.h
//  dsBridge
//
//  Created by khazan on 2023/4/12.
//

#import <Foundation/Foundation.h>
#import <dsBridge/DWKWebView.h>

//! Project version number for dsBridge.
FOUNDATION_EXPORT double dsBridgeVersionNumber;

//! Project version string for dsBridge.
FOUNDATION_EXPORT const unsigned char dsBridgeVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <dsBridge/PublicHeader.h>

#ifdef DEBUG
#define NSLog(...) NSLog(__VA_ARGS__)
#else
#define NSLog(...)
#endif


