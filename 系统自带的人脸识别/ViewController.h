//
//  ViewController.h
//  系统自带的人脸识别
//
//  Created by 王奥东 on 16/11/24.
//  Copyright © 2016年 王奥东. All rights reserved.
//

#import <UIKit/UIKit.h>

//UIProgressHUD 未被苹果写入官方SKD，但又确实存在并能调用
//用于提示等待信息等

@interface UIProgressHUD : UIView {
    UILabel *_progressMessage;
    UIImageView *_doneView;
    UIWindow *_parentWindow;
    //C位段，分配空间1字节
    struct {
        unsigned int isShowing:1;
        unsigned int isShowingText:1;
        unsigned int fixedFrame:1;
        unsigned int reserved:30;
    } _progressHUDFlags;
    
}

-(void)setText:(id)fp8;
-(void)showInView:(id)fp8;
-(void)hide;
@end

@interface ViewController : UIViewController

@end

