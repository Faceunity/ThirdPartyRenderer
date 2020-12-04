# 对接第三方 Demo 的 FaceUnity 模块
本工程是第三方 Demo 依赖的 FaceUnity 模块，每次升级 SDK 时会优先在这里改动，然后同步到各个第三方 Demo 中。
当前的 Nama SDK 版本是 **7.2.0**。

## FaceUnity 模块简介

```objc
-FUManager              //nama 业务类
-FUCamera               //视频采集类  
-authpack.h             //权限文件  
+FUAPIDemoBar     //美颜工具条,可自定义
+items            //美妆贴纸 xx.bundel文件

```

## 快速集成方法

### 一、导入 SDK
将  FaceUnity  文件夹全部拖入工程中，NamaSDK所需依赖库为 `OpenGLES.framework`、`Accelerate.framework`、`CoreMedia.framework`、`AVFoundation.framework`、`libc++.tbd`、`CoreML.framework`

- 备注: 上述NamaSDK 依赖库使用 Pods 管理 会自动添加依赖,运行在iOS11以下系统时,需要手动添加`CoreML.framework`,并在**TARGETS -> Build Phases-> Link Binary With Libraries**将`CoreML.framework`手动修改为可选**Optional**

### 二、加入展示 FaceUnity SDK 美颜贴纸效果的  UI
#### 2.1、在`FURenderViewController.m`控制器中,添加头文件并创建页面属性

```C
/** faceU */
#import "FUManager.h"
#import "FUAPIDemoBar.h"
@property (nonatomic, strong) FUAPIDemoBar *demoBar;
```

#### 2.2、加入展示美颜贴纸的UI

初始化 UI，并遵循代理  FUAPIDemoBarDelegate ，实现代理方法 `bottomDidChange:` 切换贴纸 和 `filterValueChange:` 更新美颜参数。

```C
   /** demoBar 工具条 */
    _demoBar = [[FUAPIDemoBar alloc] init];
    _demoBar.mDelegate = self;
    [self.view addSubview:_demoBar];
    [_demoBar mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(self.view.mas_bottom);
        }
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(195);
    }];

```

#### 2.3、切换贴纸

```C
// 切换贴纸
-(void)bottomDidChange:(int)index{
    if (index < 3) {
        [[FUManager shareManager] setRenderType:FUDataTypeBeautify];
    }
    if (index == 3) {
        [[FUManager shareManager] setRenderType:FUDataTypeStrick];
    }
    
    if (index == 4) {
        [[FUManager shareManager] setRenderType:FUDataTypeMakeup];
    }
    if (index == 5) {
        [[FUManager shareManager] setRenderType:FUDataTypebody];
    }
}
```

#### 2.4、更新美颜参数

```C
// 更新美颜参数
#pragma -FUAPIDemoBarDelegate
-(void)filterValueChange:(FUBeautyParam *)param{
    [[FUManager shareManager] filterValueChange:param];
    
    if (param.type == FUDataTypeFilter) { // 保存美颜滤镜
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"seletedFliter"];
        [[NSUserDefaults standardUserDefaults] setObject:param.mParam forKey:@"seletedFliter"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}
```

### 三、在 `viewDidLoad:` 中初始化 SDK 

```objc
/* faceu */
[[FUManager shareManager] loadFilter];
[FUManager shareManager].flipx = YES;
[FUManager shareManager].trackFlipx = YES;
[FUManager shareManager].isRender = YES;
```
备注: flipx的初始化值,根据贴纸是否镜像可由自己设置

### 四、在视频数据回调中 加入 FaceUnity 的数据处理,在FUCameraDelegate 处理数据
```objc
-(void)didOutputVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) ;
    imageW = CVPixelBufferGetWidth(pixelBuffer);
    imageH = CVPixelBufferGetHeight(pixelBuffer);
    [[FUManager shareManager] renderItemsToPixelBuffer:pixelBuffer];
    [self.renderView displayPixelBuffer:pixelBuffer];

    /**判断是否检测到人脸*/
    [self displayPromptText];
}
```

### 五 保存美颜参数
- 在控制销毁,或者控制器将要消失的时候,示例如下

    ```objc
- (void)dealloc{
    
    // 写入美颜参数
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *beautifyPath = [docPath stringByAppendingPathComponent:@"beautify.plist"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:beautifyPath]) {
        
        [[NSFileManager defaultManager] removeItemAtPath:beautifyPath error:nil];
    }
    
    int beautify = [self.demoBar.beautifyValueDict writeToFile:beautifyPath atomically:YES];

    
    NSLog(@"skin = %d",beautify);
    
    [[FUManager shareManager] destoryItems];
    NSLog(@"----界面销毁");
}
    ```
- 读取数据时有两个地方需要注意,一个是`FUAPIDemoBar.m` 工具条数据初始化,一个是`FUManager.m`SDK业务管理类中 `loadFilter`方法中,美颜数据的加载
- FUAPIDemoBar.m 中 对数据的处理有
    - 先判断文件中,是否有数据,构建美颜数据模型
        
        ```objc
        
        // 查看写入的美颜参数
        self.beautifyValueDict = [NSMutableDictionary dictionaryWithCapacity:25];
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *beautifyPath = [docPath stringByAppendingPathComponent:@"beautify.plist"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:beautifyPath]) { // 有写入的参数
        
        self.beautifyValueDict = [NSMutableDictionary dictionaryWithContentsOfFile:beautifyPath];
        
        }else{
    
            // 美颜默认参数
            self.beautifyValueDict = [NSMutableDictionary dictionaryWithDictionary:@{@"blur_level":@(0.7),@"color_level":@(0.3),@"red_level":@(0.3),@"sharpen":@(0.2),@"remove_pouch_strength":@(0),@"remove_nasolabial_folds_strength":@(0),@"eye_bright":@(0),@"tooth_whiten":@(0),@"cheek_thinning":@(0),@"cheek_v":@(0.5),@"cheek_narrow":@(0),@"cheek_small":@(0),@"intensity_cheekbones":@(0),@"intensity_lower_jaw":@(0),@"eye_enlarging":@(0.4),@"intensity_chin":@(0.3),  @"intensity_forehead":@(0.3),@"intensity_nose":@(0.5),@"intensity_mouth":@(0.4),@"intensity_canthus":@(0),@"intensity_eye_space":@(0.5),@"intensity_eye_rotate":@(0.5),@"intensity_long_nose":@(0.5),@"intensity_philtrum":@(0.5),@"intensity_smile":@(0)}];
        
            NSArray *beautyFilters = @[@"origin",@"ziran1",@"ziran2",@"ziran3",@"ziran4",@"ziran5",@"ziran6",@"ziran7",@"ziran8",
        @"zhiganhui1",@"zhiganhui2",@"zhiganhui3",@"zhiganhui4",@"zhiganhui5",@"zhiganhui6",@"zhiganhui7",@"zhiganhui8",@"bailiang1",@"bailiang2",@"bailiang3",@"bailiang4",@"bailiang5",@"bailiang6",@"bailiang7"
                                             ,@"fennen1",@"fennen2",@"fennen3",@"fennen5",@"fennen6",@"fennen7",@"fennen8",
                                             @"lengsediao1",@"lengsediao2",@"lengsediao3",@"lengsediao4",@"lengsediao7",@"lengsediao8",@"lengsediao11",
                                             @"nuansediao1",@"nuansediao2",
                                             @"gexing1",@"gexing2",@"gexing3",@"gexing4",@"gexing5",@"gexing7",@"gexing10",@"gexing11",
                                             @"xiaoqingxin1",@"xiaoqingxin3",@"xiaoqingxin4",@"xiaoqingxin6",
                                   @"heibai1",@"heibai2",@"heibai3",@"heibai4"];
        
            for (int i = 0; i < beautyFilters.count; i++) {
            
            [self.beautifyValueDict setValue:@(0.4) forKey:beautyFilters[i]];
            }
        
        }
        
        ```
         
- 美颜数据发生变化时滑动条的滑动,将数据变化记录到内存字典`beautifyValueDict`
 
    ```objc
    
      // 滑条滑动
      - (IBAction)filterSliderValueChange:(FUSlider *)sender {
         _seletedParam.mValue = sender.value;
    
         if (_seletedParam.type == FUDataTypeBeautify || _seletedParam.type == FUDataTypeFilter) { // 美颜参数改变

            [self.beautifyValueDict setValue:@(_seletedParam.mValue) forKey:_seletedParam.mParam];
         }
    
         if (_mDelegate && [_mDelegate respondsToSelector:@selector(filterValueChange:)]) {
            [ _mDelegate filterValueChange:_seletedParam];
         }
      }
    ```
- FUManager.m 中对数据的处理,详见 `loadFilter` 方法的调用

- 关于滤镜的处理,保存最后一个选中的滤镜,加载美颜数据时将选中滤镜赋值给FUManager.m 中的,`seletedFliter`属性
    - 参见方法在FUManager.m中 `setupFilterData`方法里面
    - 滤镜的保存
    
        ```objc
        
         -(void)filterValueChange:(FUBeautyParam *)param{
         [[FUManager shareManager] filterValueChange:param];
    
         if (param.type == FUDataTypeFilter) { // 美颜滤镜
        
         [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"seletedFliter"];
         [[NSUserDefaults standardUserDefaults] setObject:param.mParam forKey:@"seletedFliter"];
         [[NSUserDefaults standardUserDefaults] synchronize];
            
            }
    
         }
        
        ```
        
### 六、推流结束时需要销毁道具

销毁道具需要调用以下代码
```C
[[FUManager shareManager] destoryItems];
```

切换摄像头需要调用一下代码
```C
切换摄像头需要调用 [[FUManager shareManager] onCameraChange];切换摄像头
```

### 关于 FaceUnity SDK 的更多详细说明，请参看 [FULiveDemo](https://github.com/Faceunity/FULiveDemo/tree/dev)
