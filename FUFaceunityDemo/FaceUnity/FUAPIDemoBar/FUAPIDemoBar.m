//
//  FUDemoBar.m
//  FUAPIDemoBar
//
//  Created by L on 2018/6/26.
//  Copyright © 2018年 L. All rights reserved.
//

#import "FUAPIDemoBar.h"
#import "FUFilterView.h"
#import "FUSlider.h"
#import "FUBeautyView.h"
#import "FUManager.h"
#import "FUBeautyParam.h"
#import "FUDateHandle.h"


@interface FUAPIDemoBar ()<FUFilterViewDelegate, FUBeautyViewDelegate>


@property (weak, nonatomic) IBOutlet UIButton *skinBtn;
@property (weak, nonatomic) IBOutlet UIButton *shapeBtn;
@property (weak, nonatomic) IBOutlet UIButton *beautyFilterBtn;
@property (weak, nonatomic) IBOutlet UIButton *stickerBtn;
@property (weak, nonatomic) IBOutlet UIButton *makeupBtn;
@property (weak, nonatomic) IBOutlet UIButton *bodyBtn;

// 上半部分
@property (weak, nonatomic) IBOutlet UIView *topView;
// 滤镜页
@property (weak, nonatomic) IBOutlet FUFilterView *stickerView;
// 美颜滤镜页
@property (weak, nonatomic) IBOutlet FUFilterView *beautyFilterView;
@property (weak, nonatomic) IBOutlet FUFilterView *makeupView;

@property (weak, nonatomic) IBOutlet FUSlider *beautySlider;
@property (weak, nonatomic) IBOutlet FUBeautyView *bodyView;
// 美型页
@property (weak, nonatomic) IBOutlet FUBeautyView *shapeView;
// 美肤页
@property (weak, nonatomic) IBOutlet FUBeautyView *skinView;

/* 当前选中参数 */
@property (strong, nonatomic) FUBeautyParam *seletedParam;


/* 滤镜参数 */
@property (nonatomic, strong) NSArray<FUBeautyParam *> *filtersParams;
/* 美肤参数 */
@property (nonatomic, strong) NSArray<FUBeautyParam *> *skinParams;
/* 美型参数 */
@property (nonatomic, strong) NSArray<FUBeautyParam *> *shapeParams;

@property (nonatomic, strong) NSArray<FUBeautyParam *> *stickerParams;
@property (nonatomic, strong) NSArray<FUBeautyParam *> *makeupParams;
@property (nonatomic, strong) NSArray<FUBeautyParam *> *bodyParams;


@end

@implementation FUAPIDemoBar

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {self.backgroundColor = [UIColor clearColor];
        
        self.backgroundColor = [UIColor clearColor];
        NSBundle *bundle = [NSBundle bundleForClass:[FUAPIDemoBar class]];
        self = (FUAPIDemoBar *)[bundle loadNibNamed:@"FUAPIDemoBar" owner:self options:nil].firstObject;
        self.frame = frame;
    }
    return self ;
}


-(void)awakeFromNib {
    [super awakeFromNib];
    
    // 查看写入的美颜参数
    self.beautifyValueDict = [NSMutableDictionary dictionaryWithCapacity:110];
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
    
    NSLog(@"beautify = %@",self.beautifyValueDict);
    
    [self setupDate];
    [self reloadShapView:_shapeParams];
    [self reloadSkinView:_skinParams];
    [self reloadFilterView:_filtersParams];
    
    _makeupView.filters = _makeupParams;
    [_makeupView setDefaultFilter:_makeupParams[0]];
    [_makeupView reloadData];
    
    _stickerView.filters = _stickerParams;
    [_makeupView setDefaultFilter:_stickerParams[0]];
    [_stickerView reloadData];
    
    _bodyView.dataArray = _bodyParams;
    [_makeupView setDefaultFilter:_bodyParams[0]];
    _bodyView.selectedIndex = 1;
    [_bodyView reloadData];
    
    self.stickerView.mDelegate = self ;
    self.makeupView.mDelegate = self;
    self.beautyFilterView.mDelegate = self ;
    
    self.bodyView.mDelegate = self;
    self.shapeView.mDelegate = self ;
    self.skinView.mDelegate = self;
    
    [self.skinBtn setTitle:NSLocalizedString(@"美肤", nil) forState:UIControlStateNormal];
    [self.shapeBtn setTitle:NSLocalizedString(@"美型", nil) forState:UIControlStateNormal];
    [self.beautyFilterBtn setTitle:NSLocalizedString(@"滤镜", nil) forState:UIControlStateNormal];
    
    self.skinBtn.tag = 101;
    self.shapeBtn.tag = 102;
    self.beautyFilterBtn.tag = 103 ;
    self.stickerBtn.tag = 104;
    self.makeupBtn.tag = 105;
    self.bodyBtn.tag = 106;
    
}

-(void)setupDate{
    
    _skinParams = [FUDateHandle setupSkinDataWithValueDict:self.beautifyValueDict];
    _shapeParams  = [FUDateHandle setupShapDataWithValueDict:self.beautifyValueDict];
    _filtersParams = [FUDateHandle setupFilterDataWithValueDict:self.beautifyValueDict];
    
     _stickerParams = [FUDateHandle setupSticker];
     _makeupParams = [FUDateHandle setupMakeupData];
    _bodyParams  = [FUDateHandle setupBodyData];
}

-(void)layoutSubviews{
    [super layoutSubviews];
}

-(void)updateUI:(UIButton *)sender{
    self.skinBtn.selected = NO;
    self.shapeBtn.selected = NO;
    self.beautyFilterBtn.selected = NO;
    
    self.stickerBtn.selected = NO;
    self.makeupBtn.selected = NO;
    self.bodyBtn.selected = NO;
    
    
    self.skinView.hidden = YES;
    self.shapeView.hidden = YES ;
    self.beautyFilterView.hidden = YES;
    
    self.makeupView.hidden = YES;
    self.stickerView.hidden = YES;
    self.bodyView.hidden = YES;
    
    sender.selected = YES;
    
    if (sender == self.skinBtn) {
        self.skinView.hidden = NO;
    }
    if (sender == self.stickerBtn) {
        self.stickerView.hidden = NO;

    }
    if (sender == self.makeupBtn) {
        self.makeupView.hidden = NO;
    }
    if (sender == self.beautyFilterBtn) {
        self.beautyFilterView.hidden = NO;
    }
    if (sender == self.shapeBtn) {
        self.shapeView.hidden = NO;
    }
    if (sender == self.bodyBtn) {
        self.bodyView.hidden = NO;
    }
}


- (IBAction)bottomBtnsSelected:(UIButton *)sender {
    if (sender.selected) {
        sender.selected = NO ;
        [self hiddenTopViewWithAnimation:YES];
        return ;
    }
    [self updateUI:sender];
    
    if (self.shapeBtn.selected) {
        /* 修改当前UI */
        NSInteger selectedIndex = self.shapeView.selectedIndex;
        self.beautySlider.hidden = selectedIndex < 0 ;
        
        if (selectedIndex >= 0) {
            FUBeautyParam *modle = self.shapeView.dataArray[selectedIndex];
            _seletedParam = modle;
            self.beautySlider.value = modle.mValue;
        }
    }
    
    if (self.skinBtn.selected) {
        NSInteger selectedIndex = self.skinView.selectedIndex;
        self.beautySlider.hidden = selectedIndex < 0 ;
        
        if (selectedIndex >= 0) {
            FUBeautyParam *modle = self.skinView.dataArray[selectedIndex];
            _seletedParam = modle;
            self.beautySlider.value = modle.mValue;
        }
    }
    
    // slider 是否显示
    if (self.beautyFilterBtn.selected) {
        NSInteger selectedIndex = self.beautyFilterView.selectedIndex ;
        self.beautySlider.type = FUFilterSliderType01 ;
        self.beautySlider.hidden = selectedIndex <= 0;
        if (selectedIndex >= 0) {
            FUBeautyParam *modle = self.beautyFilterView.filters[selectedIndex];
            _seletedParam = modle;
            self.beautySlider.value = modle.mValue;
        }
    }
    
    if (self.stickerBtn.selected) {
        NSInteger selectedIndex = self.stickerView.selectedIndex ;
        self.beautySlider.hidden = YES;
        if (selectedIndex >= 0) {
            FUBeautyParam *modle = self.beautyFilterView.filters[selectedIndex];
            _seletedParam = modle;
        }
    }
    
    
    if (self.makeupBtn.selected) {
        NSInteger selectedIndex = self.makeupView.selectedIndex ;
        self.makeupView.type = FUFilterSliderType01 ;
        self.beautySlider.hidden = selectedIndex <= 0;
        if (selectedIndex >= 0) {
            FUBeautyParam *modle = self.makeupView.filters[selectedIndex];
            _seletedParam = modle;
            self.beautySlider.value = modle.mValue;
        }
    }

    if (self.bodyBtn.selected) {
        NSInteger selectedIndex = self.bodyView.selectedIndex;
        self.beautySlider.hidden = selectedIndex < 0 ;
        
        if (selectedIndex >= 0) {
            FUBeautyParam *modle = self.bodyView.dataArray[selectedIndex];
            _seletedParam = modle;
            self.beautySlider.value = modle.mValue;
        }
    }
    
    
    [self showTopViewWithAnimation:self.topView.isHidden];
    [self setSliderTyep:_seletedParam];
    
    if ([self.mDelegate respondsToSelector:@selector(bottomDidChange:)]) {
            [self.mDelegate bottomDidChange:sender.tag - 101];
    }
}

-(void)setSliderTyep:(FUBeautyParam *)param{
    if (param.iSStyle101) {
        self.beautySlider.type = FUFilterSliderType101;
    }else{
        self.beautySlider.type = FUFilterSliderType01 ;
    }
}


// 开启上半部分
- (void)showTopViewWithAnimation:(BOOL)animation {
    
    if (animation) {
        self.topView.alpha = 0.0 ;
        self.topView.transform = CGAffineTransformMakeTranslation(0, self.topView.frame.size.height / 2.0) ;
        self.topView.hidden = NO ;
        [UIView animateWithDuration:0.35 animations:^{
            self.topView.transform = CGAffineTransformIdentity ;
            self.topView.alpha = 1.0 ;
        }];
        
        if (self.mDelegate && [self.mDelegate respondsToSelector:@selector(showTopView:)]) {
            [self.mDelegate showTopView:YES];
        }
    }else {
        self.topView.transform = CGAffineTransformIdentity ;
        self.topView.alpha = 1.0 ;
    }
}

// 关闭上半部分
-(void)hiddenTopViewWithAnimation:(BOOL)animation {
    
    if (self.topView.hidden) {
        return ;
    }
    if (animation) {
        self.topView.alpha = 1.0 ;
        self.topView.transform = CGAffineTransformIdentity ;
        self.topView.hidden = NO ;
        [UIView animateWithDuration:0.35 animations:^{
            self.topView.transform = CGAffineTransformMakeTranslation(0, self.topView.frame.size.height / 2.0) ;
            self.topView.alpha = 0.0 ;
        }completion:^(BOOL finished) {
            self.topView.hidden = YES ;
            self.topView.alpha = 1.0 ;
            self.topView.transform = CGAffineTransformIdentity ;
            
            self.skinBtn.selected = NO ;
            self.shapeBtn.selected = NO ;
            self.beautyFilterBtn.selected = NO ;
        }];
        
        if (self.mDelegate && [self.mDelegate respondsToSelector:@selector(showTopView:)]) {
            [self.mDelegate showTopView:NO];
        }
    }else {
        
        self.topView.hidden = YES ;
        self.topView.alpha = 1.0 ;
        self.topView.transform = CGAffineTransformIdentity ;
    }
}


- (UIViewController *)viewControllerFromView:(UIView *)view {
    for (UIView *next = [view superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}


#pragma mark ---- FUFilterViewDelegate
// 开启滤镜
-(void)filterViewDidSelectedFilter:(FUBeautyParam *)param{
    _seletedParam = param;
    self.beautySlider.hidden = YES;

    if(param.type == FUDataTypeFilter&& _beautyFilterView.selectedIndex > 0){
                self.beautySlider.value = param.mValue;
        self.beautySlider.hidden = NO;
    }
    
    if(param.type == FUDataTypeMakeup&& _makeupView.selectedIndex > 0){
                self.beautySlider.value = param.mValue;
        self.beautySlider.hidden = NO;
    }
    
    if(param.type == FUDataTypebody&& _bodyView.selectedIndex > 0){
        self.beautySlider.value = param.mValue;
        self.beautySlider.hidden = NO;
    }

     [self setSliderTyep:_seletedParam];
    
    if (_mDelegate && [_mDelegate respondsToSelector:@selector(filterValueChange:)]) {
        [_mDelegate filterValueChange:_seletedParam];
    }
}

-(void)beautyCollectionView:(FUBeautyView *)beautyView didSelectedParam:(FUBeautyParam *)param{
    _seletedParam = param;
    self.beautySlider.value = param.mValue;
    self.beautySlider.hidden = NO;
    
     [self setSliderTyep:_seletedParam];
}


// 滑条滑动
- (IBAction)filterSliderValueChange:(FUSlider *)sender {
    _seletedParam.mValue = sender.value;
    
    if (_seletedParam.type == FUDataTypeBeautify || _seletedParam.type == FUDataTypeFilter) { // 美颜参数改变

        [self.beautifyValueDict setValue:@(_seletedParam.mValue) forKey:_seletedParam.mParam];
    }
    
    if (_mDelegate && [_mDelegate respondsToSelector:@selector(filterValueChange:)]) {
        [_mDelegate filterValueChange:_seletedParam];
    }
}

- (IBAction)isOpenFURender:(UISwitch *)sender {
    
    if (_mDelegate && [_mDelegate respondsToSelector:@selector(switchRenderState:)]) {
        [_mDelegate switchRenderState:sender.on];
    }
}

-(void)reloadSkinView:(NSArray<FUBeautyParam *> *)skinParams{
    _skinView.dataArray = skinParams;
    _skinView.selectedIndex = 0;
    FUBeautyParam *modle = skinParams[0];
    if (modle) {
        _beautySlider.hidden = NO;
        _beautySlider.value = modle.mValue;
    }
    [_skinView reloadData];
}

-(void)reloadShapView:(NSArray<FUBeautyParam *> *)shapParams{
    _shapeView.dataArray = shapParams;
    _shapeView.selectedIndex = 1;
    [_shapeView reloadData];
}

-(void)reloadFilterView:(NSArray<FUBeautyParam *> *)filterParams{
    _beautyFilterView.filters = filterParams;
    [_beautyFilterView reloadData];
}

-(void)setDefaultFilter:(FUBeautyParam *)filter{
    [self.beautyFilterView setDefaultFilter:filter];
}

-(BOOL)isTopViewShow {
    return !self.topView.hidden ;
}



@end
