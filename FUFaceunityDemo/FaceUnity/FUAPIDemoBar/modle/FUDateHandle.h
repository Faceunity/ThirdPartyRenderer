//
//  FUDateHandle.h
//  FULiveDemo
//
//  Created by 孙慕 on 2020/6/20.
//  Copyright © 2020 FaceUnity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FUBeautyParam.h"

NS_ASSUME_NONNULL_BEGIN

@interface FUDateHandle : NSObject

/// 美肤模型数组
/// @param valueDict 参数value值字典
+ (NSArray<FUBeautyParam *>*)setupSkinDataWithValueDict:(NSDictionary *)valueDict;

/// 美型模型数组
/// @param valueDict 参数value值字典
+ (NSArray<FUBeautyParam *>*)setupShapDataWithValueDict:(NSDictionary *)valueDict;

/// 滤镜模型数组
/// @param valueDict 参数value值字典
+ (NSArray<FUBeautyParam *>*)setupFilterDataWithValueDict:(NSDictionary *)valueDict;


+(NSArray<FUBeautyParam *>*)setupSticker;

+(NSArray<FUBeautyParam *>*)setupMakeupData;

+(NSArray<FUBeautyParam *>*)setupBodyData;
@end

NS_ASSUME_NONNULL_END
