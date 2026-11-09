//
//  RTKBBproProfile.h
//  RTKBBproSDK
//
//  Created by jerome_gu on 2019/4/11.
//  Copyright © 2019 Realtek. All rights reserved.
//

#import <RTKLEFoundation/RTKLEFoundation.h>

@class RTKBBproTTSPeripheral;

NS_ASSUME_NONNULL_BEGIN

@interface RTKBBproProfile : RTKLEProfile

@end


@interface RTKBBproTTSProfile : RTKBBproProfile
@property (nullable, readonly) RTKBBproTTSPeripheral *peripheral;
@end

NS_ASSUME_NONNULL_END
