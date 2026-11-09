//
//  RTKBBproPeripheral.h
//  RTKBBproSDK
//
//  Created by jerome_gu on 2019/4/11.
//  Copyright © 2019 Realtek. All rights reserved.
//

#import <RTKLEFoundation/RTKLEFoundation.h>

#import "RTKANCSNotificationEvent.h"
#import "RTKANCSNotificationAttribute.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSString* RTKBBproLanguageType;

extern RTKBBproLanguageType const RTKBBproLanguageUnknown;
extern RTKBBproLanguageType const RTKBBproLanguageEnglish;
extern RTKBBproLanguageType const RTKBBproLanguageChinese;
extern RTKBBproLanguageType const RTKBBproLanguageFranch;
extern RTKBBproLanguageType const RTKBBproLanguagePortuguese;



typedef NS_ENUM(NSUInteger, RTKBBproCapabilityType) {
    RTKBBproCapabilityType_LENameAccess,
    RTKBBproCapabilityType_BREDRNameAccess,
    RTKBBproCapabilityType_LanguageAccess,
    RTKBBproCapabilityType_BatteryLevelAccess,
    RTKBBproCapabilityType_OTA,
    RTKBBproCapabilityType_TTS,
    RTKBBproCapabilityType_RWS,
    RTKBBproCapabilityType_APT,
    RTKBBproCapabilityType_EQ,
    RTKBBproCapabilityType_VAD,
    RTKBBproCapabilityType_ANC,
    RTKBBproCapabilityType_ANCS,
    RTKBBproCapabilityType_Vibration,
    RTKBBproCapabilityType_MFB,
};



@interface RTKBBproPeripheral : RTKLEPeripheral

/**
 * eg. "1.2"  =  1*256 + 2
 */
@property (nonatomic, nullable) NSNumber *versionNumber;

@property (nonatomic, nullable) NSString *LEName;
@property (nonatomic, nullable) NSString *BREDRName;

@property (nonatomic, nullable) RTKBBproLanguageType currentLanguage;
@property (nonatomic, readonly, nullable) NSSet <RTKBBproLanguageType> *supportedLanguages;

@property (nonatomic, readonly, nullable) NSNumber *primaryBatteryLevel;
@property (nonatomic, readonly, nullable) NSNumber *secondaryBatteryLevel;

@property (nonatomic, nullable) NSNumber *RWSState;
@property (nonatomic, readonly, nullable) NSNumber *RwsChannel;

@property (nonatomic, nullable) NSNumber *APTState;

@property (nonatomic, readonly, nullable) NSDictionary <NSString*,NSNumber*>* DSPInfo;
@property (nonatomic, nullable) NSData *DSPEQData;


#pragma mark - Name

- (void)getInfoWithCompletion:(void(^)(BOOL success, NSError*_Nullable error, uint16_t ver))handler;



/* SOC Capability info */
@property (readonly, nonatomic) BOOL capabilitySettled;

- (BOOL)isAvailableFor:(RTKBBproCapabilityType)capability;

- (void)getCapabilityWithCompletion:(RTKLECompletionBlock)handler;

/*
 * Get the LE name of BBpro Peripheral.
 * @param completionHandler Called upon completion. If success, name is the LE name of Peripheral, else a error is provided.
 */
- (void)getLENameWithCompletion:(void(^)(BOOL success, NSError*_Nullable error, NSString *name))completionHandler;

/*
 * Set the LE name of BBpro Peripheral.
 * @param completionHandler Called upon completion. If success, success is YES and error is nil, else a error is provided.
 */
- (void)setLEName:(NSString *)name withCompletion:(void(^)(BOOL success, NSError*_Nullable error))completionHandler;

/*
 * Get the LE name of BBpro Peripheral.
 * @param completionHandler Called upon completion. If success, name is the LE name of Peripheral, else a error is provided.
 */
- (void)getBREDRNameWithCompletion:(void(^)(BOOL success, NSError*_Nullable error, NSString *name))completionHandler;

/*
 * Set the LE name of BBpro Peripheral.
 * @param completionHandler Called upon completion. If success, success is YES and error is nil, else a error is provided.
 */
- (void)setBREDRName:(NSString *)name withCompletion:(void(^)(BOOL success, NSError*_Nullable error))completionHandler;


#pragma mark - Language
/*
 * Get the language information of BBpro Peripheral.
 * @param completionHandler Called upon completion. If success, supportedLangs is a NSString array containing supported language and currentLang is a NSString representing current used language, else a error is provided.
 */
- (void)getLanguageWithCompletion:(void(^)(BOOL success, NSError*_Nullable error, NSSet <RTKBBproLanguageType>* supportedLangs, RTKBBproLanguageType currentLang))completionHandler;

/*
 * Set the current used language of BBpro Peripheral.
 * @param lang The language to set. It must be a language in supported languages, which can achive by invoke -getLanguageWithCompletion: method.
 * @param completionHandler Called upon completion. If success, supportedLangs is a NSString array containing supported language and currentLang is a NSString representing current used language, else a error is provided.
 */
- (void)setCurrentLanguage:(RTKBBproLanguageType)lang withCompletion:(void(^)(BOOL success, NSError*_Nullable error))completionHandler;


#pragma mark - Battery
/*
 * Get the battery level of BBpro Peripheral once.
 * @param completionHandler Called upon completion. If success, primary is the level of Primary component and secondary is the level of Secondary component, else a error is provided.
 */
- (void)getBatteryLevelWithCompletion:(void(^)(BOOL success, NSError*_Nullable error, NSUInteger primary, NSUInteger secondary))completionHandler;


#pragma mark - RWS
/*
 * Get the RWS state of BBpro Peripheral.
 * @param completionHandler Called upon completion. If success, state is a boolean indicating whether RWS is on, else a error is provided.
 */
- (void)getRwsStateWithCompletion:(void(^)(BOOL success, NSError*_Nullable error, BOOL state))completionHandler;

/*
 * Get the RWS channel of BBpro Peripheral.
 * @param completionHandler Called upon completion. If success, channel indicate current used channel, else a error is provided.
 */
- (void)getRwsChannelWithCompletion:(void(^)(BOOL success, NSError*_Nullable error, NSUInteger channel))completionHandler;

/*
 * Switch the RWS channel of BBpro Peripheral.
 * @param completionHandler Called upon completion. If success, channel is switched successfully, else switching fail with a error.
 */
- (void)switchRwsChannelWithCompletion:(void(^)(BOOL success, NSError*_Nullable error))completionHandler;


#pragma mark - APT
/*
 * Get the Audio Passthrough (APT) state of BBpro Peripheral.
 * @param completionHandler Called upon completion. If success, state is a boolean indicating wether APT is on or off, else a error is provided.
 */
- (void)getAPTStateWithCompletion:(void(^)(BOOL success, NSError*_Nullable error, BOOL state))completionHandler;

/*
 * Switch the Audio Passthrough (APT) state of BBpro Peripheral.
 * @param completionHandler Called upon completion. If success, APT is switched successfully, else switching fail with a error.
 */
- (void)switchAPTStateWithCompletion:(void(^)(BOOL success, NSError*_Nullable error))completionHandler;





#pragma mark - DSP
/*
 * Get DSP version information of BBpro Peripheral.
 * @param completionHandler Called upon completion. If success, info is a dictionary containning DSP Info element (a example next), else a error is provided. info Dictionary example:  @{@"Scenario": @(0x00), @"SF": @(0x03), @"ROM": @(0x01010101), @"RAM": @(0x01010101), @"Patch": @(0x01010101), @"SDK": @(0x01010101)}
 */
- (void)getDSPInfoWithCompletion:(void(^)(BOOL success, NSError*_Nullable error, NSDictionary <NSString*,NSNumber*>*_Nullable info))completionHandler;
//- (void)getDSPEQWithCompletion:(void(^)(BOOL success, NSError*_Nullable error, NSData*_Nullable))completionHandler;

/**
 * Set DSP EQ
 * @param paramterData Data to modify DSP EQ. The data should be return by call -[RTKBBproEQSetting serializedDataOfNot48K] or -[RTKBBproEQSetting serializedDataOf48K] method.
 * @param completionHandler This block is called upon completion. If the action take effect then success is YES and error is nil. Otherwise success is NO with an error.
 * @discussion Specific to some implementation, you should set EQ for 44.1k(-serializedDataOfNot48K) and 48k(-serializedDataOf48K) all at once to make DSP effective really.
 */
- (void)setDSPEQ:(NSData *)paramterData withCompletion:(void(^)(BOOL success, NSError*_Nullable error))completionHandler;

/**
 * Clear DSP EQ setting
 * @param completionHandler This block is called upon completion. If the action take effect then success is YES and error is nil. Otherwise success is NO with an error.
 */
- (void)clearDSPEQWithCompletion:(void(^)(BOOL success, NSError*_Nullable error))completionHandler;

@end


/**
 * A bitmask value indicate the EQ Setting index.
 * @discussion When used as current EQ Index only one current Index bit set to 1, when usded as supported EQ Indexes, all supported EQ index set to 1.
 */
typedef NS_OPTIONS(uint16_t, RTKBBproEQIndex) {
    RTKBBproEQIndexOff = 1 << 0,
    RTKBBproEQIndexCustomer1 = 1 << 1,  /* Bass Boost */
    RTKBBproEQIndexCustomer2 = 1 << 2,  /* Normal */
    RTKBBproEQIndexCustomer3 = 1 << 3,  /* Treble */
    RTKBBproEQIndexBuiltin1 = 1 << 4,
    RTKBBproEQIndexBuiltin2 = 1 << 5,
    RTKBBproEQIndexBuiltin3 = 1 << 6,
    RTKBBproEQIndexBuiltin4 = 1 << 7,
    RTKBBproEQIndexBuiltin5 = 1 << 8,
    RTKBBproEQIndexRealtime = 1 << 9,       /* The EQ be adjusted in UI */
};


/**
 * EQ related operation.
 * Only available when version >= 1.0
 */
@interface RTKBBproPeripheral (EQ)

@property (nonatomic, readonly) NSNumber *EQStatus;
- (void)getEQStatusWithCompletion:(void(^)(BOOL success, NSError*_Nullable error, BOOL isOn))completionHandler;

- (void)setEQEnable:(BOOL)enable withCompletion:(void(^)(BOOL success, NSError*_Nullable error))completionHandler;

@property (nonatomic, readonly) NSNumber *EQCount;
- (void)getEQEntryCountWithCompletion:(void(^)(BOOL success, NSError*_Nullable error, NSUInteger count))completionHandler;

@property (nonatomic, readonly) NSNumber *EQIndex;
- (void)getCurrentEQIndexWithCompletion:(void(^)(BOOL success, NSError*_Nullable error, NSUInteger EQIndex))completionHandler;

- (void)setCurrentEQIndex:(NSUInteger)index completion:(void(^)(BOOL success, NSError*_Nullable error))completionHandler;

- (void)getEQParameterOfIndex:(NSUInteger)index completion:(void(^)(BOOL success, NSError*_Nullable error, NSData *EQData))completionHandler;

- (void)setEQParameterOfIndex:(NSUInteger)index EQData:(NSData *)data completion:(void(^)(BOOL success, NSError*_Nullable error))completionHandler;

@end


@interface RTKBBproPeripheral (LGProject)

#warning EQ Index, Vibration and ANCS is only applicable to LG project.

@property (nonatomic, nullable) NSNumber *currentEQIndex;
@property (nonatomic, readonly, nullable) NSNumber *supportedEQIndexes;

@property (nonatomic, nullable) NSNumber *vibrationEnable;


@property (nonatomic, readonly, nullable) RTKANCSNotificationEvent *lastANCSEvent;
@property (nonatomic, readonly, nullable) RTKANCSNotificationAttribute *lastANCSAttr;


#pragma mark -  EQ Index
/**
 * Get EQ Setting index of peripheral
 * @param completionHandler This block is called upon completion. If the action take effect then success is YES and error is nil, and parameter currentIndex is the the EQ Setting Index current used in Peripheral, supportedIndexes is a bit field which indicate supported Indexes. Otherwise success is NO with an error.
 * @see RTKBBproEQIndex type
 */
- (void)getEQIndexStateWithCompletion:(void(^)(BOOL success, NSError*_Nullable error, RTKBBproEQIndex currentIndex, RTKBBproEQIndex supportedIndexes))completionHandler;

/**
 * Set current used EQ Setting of peripheral
 * @param index A bitmask whose EQ Setting to use bit set 1.
 * @see RTKBBproEQIndex type
 */
- (void)setEQIndex:(RTKBBproEQIndex)index withCompletion:(void(^)(BOOL success, NSError*_Nullable error))completionHandler;


#pragma mark - Vibration
/**
 * Get Peripheral Vibration Status
 * @param completionHandler This block is called upon completion. If the action take effect then success is YES and error is nil, and state indicate whether vibration is on. Otherwise success is NO with an error.
 */
- (void)getVibrationStatusWithCompletion:(void(^)(BOOL success, NSError*_Nullable error, BOOL state))completionHandler;

///**
// *
// */
//- (void)getVibrationModeWithCompletion:(void(^)(BOOL success, NSError*_Nullable error, uint16_t, uint16_t, uint8_t))completionHandler;

/**
 * Enable or disable Vibration
 * @param enabled Control whether peripheral vibration function enable.
 * @param completionHandler This block is called upon completion. If the action take effect then success is YES and error is nil. Otherwise success is NO with an error.
 */
- (void)setVibrationEnable:(BOOL)enabled withCompletion:(void(^)(BOOL success, NSError*_Nullable error))completionHandler;

/**
 * Toggle vibration function
 * @param completionHandler This block is called upon completion. If the action take effect then success is YES and error is nil. Otherwise success is NO with an error.
 */
- (void)toggleVibrationWithCompletion:(void(^)(BOOL success, NSError*_Nullable error))completionHandler;

/**
 * Stop in progress vibration
 * @param completionHandler This block is called upon completion. If the action take effect then success is YES and error is nil. Otherwise success is NO with an error.
 * @discussion Only function when a happening vibration
 */
- (void)stopVibrationWithCompletion:(void(^)(BOOL success, NSError*_Nullable error))completionHandler;

/**
 * Set vibration behavior pattern
 * @param on On period time (10ms/uinit)
 * @param off Off period time (10ms/uinit)
 * @param count Vibrate repeat count
 * @param completionHandler This block is called upon completion. If the action take effect then success is YES and error is nil. Otherwise success is NO with an error.
 */
- (void)setVibrationModeWithOnPeriod:(NSUInteger)on offPeriod:(NSUInteger)off repeat:(NSUInteger)count completion:(void(^)(BOOL success, NSError*_Nullable error))completionHandler;


#pragma mark - ANCS

/**
 * Make SOC to use ANCS
 * @param completionHandler This block is called upon completion. If the action take effect then success is YES and error is nil. Otherwise success is NO with an error.
 * @discussion Only function when a happening vibration
 */
- (void)registerANCSWithCompletion:(void(^)(BOOL success, NSError*_Nullable error))completionHandler;


@end



typedef NS_ENUM(uint8_t, RTKBBproPeripheralMMIType) {
    RTKBBproPeripheralMMIType_Null      = 0x00,
    RTKBBproPeripheralMMIType_VoiceDail = 0x09,
    RTKBBproPeripheralMMIType_VolUp     = 0x30,
    RTKBBproPeripheralMMIType_VolDown   = 0x31,
    RTKBBproPeripheralMMIType_PlayPause = 0x32,
    RTKBBproPeripheralMMIType_Forward   = 0x34,
    RTKBBproPeripheralMMIType_Backward  = 0x35,
    RTKBBproPeripheralMMIType_APT       = 0x65,
    RTKBBproPeripheralMMIType_EQSwitch  = 0x6B,
    
    RTKBBproPeripheralMMIType_NotSet  = 0xFF,
};

typedef NS_ENUM(uint8_t, RTKBBproPeripheralBudType) {
    RTKBBproPeripheralBudType_Default,
    RTKBBproPeripheralBudType_Left,
    RTKBBproPeripheralBudType_Right,
};

typedef NS_ENUM(uint8_t, RTKBBproPeripheralMMIStatus) {
    RTKBBproPeripheralMMIStatus_Idle,
    RTKBBproPeripheralMMIStatus_InCall,
};

typedef NS_ENUM(uint8_t, RTKBBproPeripheralMMIClickType) {
    RTKBBproPeripheralMMIClickType_Single,
    RTKBBproPeripheralMMIClickType_Multi2,
    RTKBBproPeripheralMMIClickType_Multi3,
    RTKBBproPeripheralMMIClickType_LongPress,
    RTKBBproPeripheralMMIClickType_UtralLongPress,
};

typedef struct {
    RTKBBproPeripheralBudType bud;
    RTKBBproPeripheralMMIStatus status;
    RTKBBproPeripheralMMIClickType click;
    RTKBBproPeripheralMMIType MMI;
} RTKBBproMMIMapping;


@interface RTKBBproPeripheral (MMI)

@property (nonatomic, readonly, nullable) NSArray <NSNumber*> *supportedMMIs;
- (void)getSupportedMMIsWithCompletionHandler:(RTKLECompletionBlock)handler;

@property (nonatomic, readonly, nullable) NSArray <NSNumber*> *supportedClicks;
- (void)getSupportedClicksWithCompletionHandler:(RTKLECompletionBlock)handler;


@property (nonatomic, readonly, nullable) NSArray <NSNumber*> *supportedPhoneStatus;
- (void)getSupportedPhoneStatusWithCompletionHandler:(RTKLECompletionBlock)handler;

@property (nonatomic, readonly, nullable) NSArray <NSValue*> *MMIKeyMappings;
- (void)getMMIKeyMappingWithCompletionHandler:(RTKLECompletionBlock)handler;

- (void)setMMIKeyMapping:(RTKBBproMMIMapping)mapping withCompletionHandler:(RTKLECompletionBlock)handler;

@property (nonatomic, readonly, nullable) NSNumber *buttonLocked;
- (void)getMMIButtonLockStateWithCompletionHandler:(RTKLECompletionBlock)handler;

- (void)switchMMIButtonLockStateWithCompletionHandler:(RTKLECompletionBlock)handler;

@end




@interface RTKBBproPeripheral (APTGain)

@property (nonatomic, readonly, nullable) NSNumber *APTNRStatus;
- (void)getAPTNRStatusWithCompletionHandler:(void(^)(BOOL success, NSError*_Nullable error))handler;
- (void)switchAPTNROnOffWithCompletion:(RTKLECompletionBlock)completionHandler;

@property (nonatomic, readonly, nullable) NSNumber *APTGainLevel;

/* KVO not applicable */
@property (nonatomic, readonly, nullable) NSNumber *maximumAPTGainLevel;

- (void)getAPTGainLevelWithCompletionHandler:(void(^)(BOOL success, NSError*_Nullable error, NSUInteger gain, NSUInteger maxGain))handler;

- (void)setAPTGainLevel:(NSUInteger)level withCompletionHandler:(RTKLECompletionBlock)handler;

- (void)increaseAPTGainLevelWithCompletionHandler:(RTKLECompletionBlock)handler;
- (void)decreaseAPTGainLevelWithCompletionHandler:(RTKLECompletionBlock)handler;

@end


NS_ASSUME_NONNULL_END
