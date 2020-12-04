//
//  FURenderViewController.m
//  FUFaceunityDemo
//
//  Created by support on 2020/12/1.
//  Copyright © 2020 support. All rights reserved.
//

#import "FURenderViewController.h"

#import <Masonry.h>
#import <SVProgressHUD.h>

/**faceu */
#import "FUManager.h"
#import "FUCamera.h"
#import "FUOpenGLView.h"
#import "FUAPIDemoBar.h"


@interface FURenderViewController ()<FUCameraDelegate,FUCameraDataSource,FUAPIDemoBarDelegate>{

    float imageW;
    float imageH;
    
}

/**摄像头采集 */
@property(nonatomic, strong) FUCamera *mCamera;

/**展示视图 */
@property(nonatomic, strong) FUOpenGLView *renderView;

/** 人脸检测 */
@property (strong, nonatomic) UILabel *noTrackLabel;

/** 工具条 */
@property(nonatomic, strong)  FUAPIDemoBar*demoBar;



@end

@implementation FURenderViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithRed:17/255.0 green:18/255.0 blue:38/255.0 alpha:1.0];
    
    [self setupSubView];
    
    //重置曝光值为0
    [self.mCamera setExposureValue:0];
    
    /* faceu */
    [[FUManager shareManager] loadFilter];
    [FUManager shareManager].flipx = YES;
    [FUManager shareManager].trackFlipx = YES;
    [FUManager shareManager].isRender = YES;
    
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.mCamera startCapture];
    [_mCamera changeSessionPreset:AVCaptureSessionPreset1280x720];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.mCamera resetFocusAndExposureModes];
    [self.mCamera stopCapture];
    
    /* 清一下信息，防止快速切换有人脸信息缓存 */
    [[FUManager shareManager] onCameraChange];
    
}

#pragma mark ---------UI

/// 初始化界面
- (void)setupSubView{
    
    /** opengl */
    _renderView = [[FUOpenGLView alloc] init];
    _renderView.layer.masksToBounds = YES;
    [self.view addSubview:_renderView];
    
    [_renderView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
            if(iPhoneXStyle){
                make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).mas_offset(-50);
            }else{
                make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
            }
        } else {
            // Fallback on earlier versions
            make.top.equalTo(self.view.mas_top);
            make.bottom.equalTo(self.view.mas_bottom);
        }
        
    }];
    
    /* 未检测到人脸提示 */
    _noTrackLabel = [[UILabel alloc] init];
    _noTrackLabel = [[UILabel alloc] init];
    _noTrackLabel.textColor = [UIColor whiteColor];
    _noTrackLabel.font = [UIFont systemFontOfSize:17];
    _noTrackLabel.textAlignment = NSTextAlignmentCenter;
    _noTrackLabel.text = NSLocalizedString(@"No_Face_Tracking", @"未检测到人脸");
    [self.view addSubview:_noTrackLabel];
    [_noTrackLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.mas_equalTo(140);
        make.height.mas_equalTo(22);
    }];
    
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
    
}


#pragma mark -  Loading

-(FUCamera *)mCamera {
    if (!_mCamera) {
        _mCamera = [[FUCamera alloc] init];
        _mCamera.delegate = self ;
        _mCamera.dataSource = self;
    }
    return _mCamera ;
}


#pragma mark - FUCameraDelegate
static NSTimeInterval totalRenderTime = 0;
static  NSTimeInterval oldTime = 0;
-(void)didOutputVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) ;
    imageW = CVPixelBufferGetWidth(pixelBuffer);
    imageH = CVPixelBufferGetHeight(pixelBuffer);
    [[FUManager shareManager] renderItemsToPixelBuffer:pixelBuffer];
    [self.renderView displayPixelBuffer:pixelBuffer];

    /**判断是否检测到人脸*/
    [self displayPromptText];
}

#pragma mark - FUCameraDataSource
-(CGPoint)faceCenterInImage:(FUCamera *)camera{
    CGPoint center = CGPointMake(-1, -1);
    BOOL isHaveFace = [[FUManager shareManager] isTracking];
    
    if (isHaveFace) {
        center = [self cameraFocusAndExposeFace];
    }
//    NSLog(@"人脸曝光点-----%@",NSStringFromCGPoint(center));
    return center;
}


-(CGPoint)cameraFocusAndExposeFace{
    CGPoint center = [[FUManager shareManager] getFaceCenterInFrameSize:CGSizeMake(imageW, imageH)];
   return  CGPointMake(center.y, self.mCamera.isFrontCamera ? center.x : 1 - center.x);
}


-(void)displayPromptText{

    if ([FUManager shareManager].currentType == FUDataTypebody) {
        
        int res = fuHumanProcessorGetNumResults();
        dispatch_async(dispatch_get_main_queue(), ^{

            self.noTrackLabel.text = @"未检测到人体";
            self.noTrackLabel.hidden = res > 0 ? YES : NO;
        });
        
    }else{
    
         BOOL isHaveFace = [[FUManager shareManager] isTracking];
        dispatch_async(dispatch_get_main_queue(), ^{
    
            self.noTrackLabel.text = @"未检测到人脸";
            self.noTrackLabel.hidden = isHaveFace;
        });
        
    }
    
}

-(FUNamaHandleType)getNamaRenderType{
    return 0;
}



/// 切换摄像头
/// @param sender mCameraSwitch
-(void)headButtonViewSwitchAction:(UIButton *)sender{
    sender.userInteractionEnabled = NO ;
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
    dispatch_after(delayTime, dispatch_get_main_queue(), ^(void){
        sender.userInteractionEnabled = YES ;
    });
    if (![self.mCamera supportsAVCaptureSessionPreset:sender.selected]) {//硬件不支持 降低一个分辨率
//        _selIndex = _selIndex - 1;
//        [self fuPopupMenuDidSelectedAtIndex:_selIndex];
        
        [SVProgressHUD showErrorWithStatus:@"设置分辨率较高"];
    }
    
    [self.mCamera changeCameraInputDeviceisFront:sender.selected];
    /**切换摄像头要调用此函数*/
    [[FUManager shareManager] onCameraChange];
    sender.selected = !sender.selected ;
}

#pragma mark -  FUAPIDemoBarDelegate

#pragma -FUAPIDemoBarDelegate
-(void)filterValueChange:(FUBeautyParam *)param{
    [[FUManager shareManager] filterValueChange:param];
    
    if (param.type == FUDataTypeFilter) { // 保存美颜滤镜
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"seletedFliter"];
        [[NSUserDefaults standardUserDefaults] setObject:param.mParam forKey:@"seletedFliter"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

-(void)switchRenderState:(BOOL)state{
    [FUManager shareManager].isRender = state;
}

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


@end
