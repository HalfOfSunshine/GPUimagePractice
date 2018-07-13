//
//  NSObject+MKUtil.m
//  NLGPUImageCamera
//
//  Created by kkmm on 2018/6/8.
//  Copyright © 2018年 kkmm. All rights reserved.
//

#import "NSObject+MKUtil.h"
#import <MBProgressHUD/MBProgressHUD.h>

@implementation NSObject (MKUtil)
//toast消息框
+(void)toastMessage:(NSString*)text
{
	//    UIWindow *window = [[UIApplication sharedApplication] windows][0];
	dispatch_async(dispatch_get_main_queue(), ^{
		UIWindow *window = [[UIApplication sharedApplication] keyWindow];
		[self toastMessage:text withView:window];
	});
}
+(void)toastMessage:(NSString*)text withView:(UIView*)view{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
	
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
	
	// Configure for text only and offset down
	hud.mode = MBProgressHUDModeText;
	//    hud.labelText = text;
	
	hud.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.8];
	hud.contentColor = [UIColor whiteColor];
	hud.detailsLabel.text = text;
	hud.detailsLabel.font = [UIFont systemFontOfSize:15.0f];
	hud.opacity = 0.8;
	hud.margin = 10.f;
	hud.yOffset = 120.f;
	hud.removeFromSuperViewOnHide = YES;
	hud.userInteractionEnabled=NO;
	
	[hud hideAnimated:YES afterDelay:2.0f];
#pragma clang diagnostic pop
	
}
@end
