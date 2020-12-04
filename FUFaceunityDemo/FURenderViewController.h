//
//  FURenderViewController.h
//  FUFaceunityDemo
//
//  Created by support on 2020/12/1.
//  Copyright © 2020 support. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define KScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define KScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define  iPhoneXStyle ((KScreenWidth == 375.f && KScreenHeight == 812.f ? YES : NO) || (KScreenWidth == 414.f && KScreenHeight == 896.f ? YES : NO))

@interface FURenderViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
