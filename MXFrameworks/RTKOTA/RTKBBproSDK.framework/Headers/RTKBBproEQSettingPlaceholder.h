//
//  RTKBBproEQSettingPlaceholder.h
//  RTKBBproSDK
//
//  Created by jerome_gu on 2019/7/8.
//  Copyright © 2019 Realtek. All rights reserved.
//

#import <RTKBBproSDK/RTKBBproSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface RTKBBproEQSettingPlaceholder : RTKBBproEQSetting

@property (nonatomic, readonly) BOOL containParameterData;
- (void)setParameterData:(NSData *)parameterData;

@end

NS_ASSUME_NONNULL_END
