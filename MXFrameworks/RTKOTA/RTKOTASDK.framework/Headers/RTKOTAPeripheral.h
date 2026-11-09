//
//  RTKOTAPeripheral.h
//  RTKOTASDK
//
//  Created by jerome_gu on 2019/4/16.
//  Copyright © 2019 Realtek. All rights reserved.
//

#if USE_LEFOUNDATION_STATIC_LIBRARY
#import "RTKLEFoundationUmbrella.h"
#else
#import <RTKLEFoundation/RTKLEFoundation.h>
#endif

#import "RTKOTAFormat.h"
#import "RTKOTABin.h"

NS_ASSUME_NONNULL_BEGIN


typedef enum : NSUInteger {
    RTKOTAProtocolTypeGATTSPP  =  0x0000,
    RTKOTAProtocolTypeGATT  =   0x0010,
    RTKOTAProtocolTypeSPP =   0x0011,
} RTKOTAProtocolType;


typedef enum : NSUInteger {
    RTKOTAEarbudUnkown,
    RTKOTAEarbudLeft,
    RTKOTAEarbudRight,
} RTKOTAEarbud;




@class RTKOTAPeripheral;

@protocol RTKOTAPeripheralDelegate <RTKLEPeripheralDelegate>

/**
 * Invoked when RTKOTAClient has determined information about OTA.
 */
- (void)OTAPeripheral:(RTKOTAPeripheral *)peripheral didDetermineInfoWithError:(nullable NSError*)error;

@end



@interface RTKOTAPeripheral : RTKLEPeripheral

@property (readonly) BOOL infoSettled;

@property (nonatomic, weak) id <RTKOTAPeripheralDelegate> delegate;

/**
 * OTA process version
 */
@property (readonly) NSUInteger OTAVersion;

@property (readonly) NSUInteger securityVersion;

@property (readonly) BDAddressType bdAddress;
@property (readonly) BDAddressType companionBDAddress;

@property (readonly) uint16_t appVersion;
@property (readonly) uint16_t patchVersion;

@property (readonly) NSString *linkKey;
@property (readonly) NSUInteger tempBufferSize;

@property (readonly) NSUInteger freeBank;
@property (readonly) NSUInteger appFreeBank;
@property (readonly) NSUInteger patchFreeBank;

@property (readonly) BOOL bufferCheckEnable;
@property (readonly) BOOL AESEnable;
@property (readonly) NSUInteger encryptionMode;
@property (readonly) BOOL copyImage;
@property (readonly) BOOL updateMultiImages;

/* RWS Upgrade related properties */
/**
 Whether this peripheral is a one of the RWS pair.
 */
@property (readonly) BOOL isRWS;

/**
 Indicate what bud is this perpheral.
 */
@property (readonly) RTKOTAEarbud budType;

/**
Indicate whether RWS bug is in engaged.
*/
@property (readonly) BOOL notEngaged;


/**
 Indicate whether this peripheral have received images right now, but not active.
 */
@property (readonly) BOOL upgradedCurrently;

@property (readonly) uint32_t imageIndicator;

@property (readonly) RTKOTAProtocolType protocolType;

/**
 * The executable bins installed in Realtek peripheral.
 */
@property (readonly) NSArray <RTKOTABin*> *bins;




/**
 * Indicate whether related peripheral can translate to OTA mode, and wether -enterOTAMode method can be invoked.
 */
@property (readonly) BOOL canEnterOTAMode;

/**
 * Indicate whether related peripheral can DFU upgrade immediately.
 */
@property (readonly) BOOL canUpgradeSliently;


/**
 * Request peripheral translate to OTA mode.
 * @discussion In translating to OTA mode, the Peripheral first get disconnected, and reboot as a different peripheral (while advertising same address). When the OTA mode peripheral be scanned, RTKOTAClientDelegate -OTAClient:didEnterOTAModeWithPeripheral: get invoked with the peripheral.
 */
- (void)enterOTAMode;

@end


NS_ASSUME_NONNULL_END
