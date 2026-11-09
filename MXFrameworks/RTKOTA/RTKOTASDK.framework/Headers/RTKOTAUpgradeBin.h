//
//  RTKOTAImage.h
//  RTKOTASDK
//
//  Created by jerome_gu on 2019/1/28.
//  Copyright © 2019 Realtek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTKOTABin.h"

typedef NS_ENUM(NSUInteger, RTKOTABinBankInfo) {
    RTKOTABinBankInfo_Unknown,
    RTKOTABinBankInfo_Bank0,
    RTKOTABinBankInfo_Bank1,
};


@class RTKOTAPeripheral;

NS_ASSUME_NONNULL_BEGIN

/**
 * 代表一个OTA升级的bin单元
 */
@interface RTKOTAUpgradeBin : RTKOTABin

@property (readonly) NSUInteger otaVersion;

@property (readonly) NSUInteger secVersion;

@property (readonly) NSUInteger imageId;

@property (readonly) NSData *data;

@property (nonatomic) RTKOTABinBankInfo bank;

- (instancetype)initWithPureData:(NSData *)data;


@property (nonatomic, readonly) BOOL ICDetermined;

// Assign the OTA target peripheral IC subjectively.
// @discussion You should call this method only if property ICDetermined is NO. You should make sure the upgrade Bin matches target peripheral, otherwise, the behaviour is not determined.
- (void)assertAvailableForPeripheral:(RTKOTAPeripheral *)peripheral;


+ (nullable NSArray <RTKOTAUpgradeBin*> *)imagesExtractFromMPPackFilePath:(NSString *)path error:(NSError *__nullable *__nullable)errPtr;

+ (nullable NSArray <RTKOTAUpgradeBin*> *)imagesExtractFromMPPackFileData:(NSData *)data error:(NSError *__nullable *__nullable)errPtr;


+ (nullable NSError*)extractCombinePackFileWithFilePath:(NSString *)path toPrimaryBins:(NSArray <RTKOTAUpgradeBin*> *_Nullable*_Nullable)primaryBinsRef secondaryBins:(NSArray <RTKOTAUpgradeBin*> *_Nullable*_Nullable)secondaryBinsRef;


@end

NS_ASSUME_NONNULL_END
