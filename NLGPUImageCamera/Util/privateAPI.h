//
//  privateAPI.h
//  NLGPUImageCamera
//
//  Created by kkmm on 2018/6/7.
//  Copyright © 2018年 kkmm. All rights reserved.
//

#ifndef privateAPI_h
#define privateAPI_h

#define USERDEFAULTS [NSUserDefaults standardUserDefaults]
#define FUll_VIEW_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define FUll_VIEW_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define TopBar_H 44
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#endif /* privateAPI_h */
