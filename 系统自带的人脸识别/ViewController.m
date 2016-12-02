//
//  ViewController.m
//  系统自带的人脸识别
//
//  Created by 王奥东 on 16/11/24.
//  Copyright © 2016年 王奥东. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIView * viewShow;
@end

@implementation ViewController {
    
    
    UIProgressHUD * _progressHUD;
    CGRect   _rectFaceDetect; // 脸部轮廓的范围
    
    IBOutlet UIImageView *_menuImgView;
    IBOutlet UILabel *_detailLabel;
    
    IBOutlet UIButton *_recognizeButton;
    
    IBOutlet UIButton *_chaneButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)show:(id)sender {
    
    [self showProgressIndicator:@""];
}


- (IBAction)change:(id)sender {
    
    UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"更改人脸" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"1",@"2", nil];
    [a show];
}

#pragma mark - 图片显示的处理
-(void)setShowViewFrame {
    
    CGFloat scale = 1;
    //图片的size
    CGSize imgSize = _menuImgView.image.size;
    //控制器的frame
    CGRect viewControllerFrame = self.view.frame;
    //背景view的frame
    CGRect viewShowFrame = _viewShow.frame;
    
    //图片宽大于图片高
    if (imgSize.width/CGRectGetWidth(viewControllerFrame) > imgSize.height/CGRectGetHeight(viewControllerFrame)) {
        //将背景view的宽设为屏幕的宽
        viewShowFrame.size.width = CGRectGetWidth(viewControllerFrame);
        //同比例设置高
        viewShowFrame.size.height = imgSize.height * CGRectGetWidth(viewControllerFrame) / imgSize.width;
        //获取扩大/缩小时的比例
        scale = CGRectGetWidth(viewControllerFrame)/imgSize.width;
    }else {
        //图片宽小于图片高
        //上同
        viewShowFrame.size.height = CGRectGetHeight(viewControllerFrame);
        viewShowFrame.size.width = imgSize.width * CGRectGetHeight(viewControllerFrame) / imgSize.height;
        scale = CGRectGetHeight(viewControllerFrame) / imgSize.height;
    }
    
    
    //图片进行缩放后应根据内容的改变而改变自身
    //重新设置viewShow的x y
    viewShowFrame.origin.x = (CGRectGetWidth(viewControllerFrame) - CGRectGetWidth(viewShowFrame))/2;
    viewShowFrame.origin.y = viewControllerFrame.origin.y + (CGRectGetHeight(viewControllerFrame) - CGRectGetHeight(viewShowFrame))/2;
    _viewShow.frame = viewShowFrame;
    
    //根据比例缩放图片
    UIImage *newImg = [self scaleImage:_menuImgView.image toScale:scale];
    _menuImgView.image = newImg;
}

#pragma mark - 开始人脸检测
-(void)dealImageWhenItChanged {
    
    //图片显示的处理
    [self setShowViewFrame];
    
    //脸部特征范围
    _rectFaceDetect = CGRectZero;
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //人脸检测
        [self faceDetect:_menuImgView.image];
    });
    
}

#pragma mark - 移除检测的标记
-(void)removeAllMarkViews {
    
    //清除原来标记的View
    for (UIView *vv in self.viewShow.subviews) {
        if (vv.tag == 100) {
            [vv removeFromSuperview];
        }
    }
    
}

#pragma mark - 人脸检测
-(void)faceDetect:(UIImage *)aImage {
    //创建一个关于图片的CIImage信息
    CIImage *image = [CIImage imageWithCGImage:aImage.CGImage];
    //创建一个脸部检测器
    //此处是CIDetectorAccuracyHigh，若用于real-time（实时）的人脸检测，则用CIDetectorAccuracyLow，更快
    NSDictionary *opts = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
    
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:opts];
    
    //输出面部特征并标记他们
    //如果features的count为0代表失败
    NSArray *features = [detector featuresInImage:image];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //面部检测结果提示
        [self markAfterFaceDetect:features];
        
    });
    
}

#pragma mark - 面部检测结果提示
-(void)markAfterFaceDetect:(NSArray *)features {
    //隐藏提示
    [self hideProgressIndicator];
    
    [self setShowViewFrame];
    //count为0代表失败
    if ([features count] == 0) {
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"失败" message:@"请不要使用后脑勺识别~" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alter show];
        return;
    }
    //获取面部特征
    for (CIFaceFeature *f in features) {
        //旋转180°，仅y
        
        //获取特征的范围
        CGRect aRect = f.bounds;
        
        aRect.origin.y = self.viewShow.bounds.size.height - aRect.size.height - aRect.origin.y;
        
        UIView *vv = [[UIView alloc] initWithFrame:aRect];
        vv.tag = 100;
        [vv setTransform:CGAffineTransformMakeScale(1, -1)];
        vv.backgroundColor = [UIColor redColor];
        vv.alpha = 0.6;
        [self.viewShow addSubview:vv];
        
        _rectFaceDetect = aRect;
        
        //左眼
        if (f.hasLeftEyePosition) {
            UIView *vv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
            vv.tag = 100;
            //旋转180，仅y
            CGPoint newCenter = f.leftEyePosition;
            newCenter.y = self.viewShow.bounds.size.height - newCenter.y;
            vv.center = newCenter;
            
            vv.backgroundColor = [UIColor yellowColor];
            [vv setTransform:CGAffineTransformMakeScale(1, -1)];
            vv.alpha = 0.6;
            [self.viewShow addSubview:vv];
            
        }
        //右眼
        if (f.hasRightEyePosition) {
            UIView *vv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
            vv.tag = 100;
            //旋转180,仅y
            CGPoint newCenter = f.rightEyePosition;
            newCenter.y = self.viewShow.bounds.size.height - newCenter.y;
            vv.center = newCenter;
            
            vv.backgroundColor = [UIColor blueColor];
            [vv setTransform:CGAffineTransformMakeScale(1, -1)];
            vv.alpha = 0.6;
            [self.viewShow addSubview:vv];
        }
        //嘴
        if (f.hasMouthPosition) {
            UIView *vv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
            vv.tag = 100;
            //旋转180，仅y
            CGPoint newCenter = f.mouthPosition;
            newCenter.y = self.viewShow.bounds.size.height - newCenter.y;
            vv.center = newCenter;
            
            vv.backgroundColor = [UIColor greenColor];
            [vv setTransform:CGAffineTransformMakeScale(1, -1)];
            vv.alpha = 0.6;
            [self.viewShow addSubview:vv];
        }
    }
    
}

#pragma mark - 图片缩放
-(UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize {
    
    if (image) {
        UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
        [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return scaledImage;
    }
    return nil;
}

#pragma mark - 显示指示器
-(void)showProgressIndicator:(NSString *)text {
    self.view.userInteractionEnabled = FALSE;
    if (!_progressHUD) {
        CGFloat w = 160.0f, h = 120.0f;
        _progressHUD = [[UIProgressHUD alloc] initWithFrame:CGRectMake((self.view.frame.size.width - w)/2, (self.view.frame.size.height - h) /2, w, h)];
        [_progressHUD showInView:self.view];
    }
    [self performSelector:@selector(dealImageWhenItChanged) withObject:self afterDelay:0.5];
}

#pragma mark - 隐藏指示器
-(void)hideProgressIndicator{
    self.view.userInteractionEnabled = TRUE;
    if (_progressHUD) {
        [_progressHUD hide];
        _progressHUD = nil;
    }
}

#pragma mark - alert delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *b = [alertView buttonTitleAtIndex:buttonIndex];
    //是否选择了Delete按钮
    if ([b isEqualToString:@"1"]) {
        _menuImgView.image = [UIImage imageNamed:@"1.jpg"];
       
    }else {
        _menuImgView.image = [UIImage imageNamed:@"2.jpg"];
    }
    _detailLabel.hidden = YES;
    [self removeAllMarkViews];
}

@end
