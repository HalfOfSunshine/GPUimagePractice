//
//  NLVideoProcessViewController.h
//  NLGPUImageCamera
//
//  Created by kkmm on 2018/6/26.
//  Copyright © 2018年 kkmm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GPUImage/GPUImage.h>

@interface VideoProcessViewController : UIViewController{
	GPUImageMovie *gpuMovieFile;
	GPUImageOutput<GPUImageInput> *filter;
	NSString *gpuMoviePath;
	NSURL *gpuMovieURL;
	NSTimer * gpuProgressTimer;

	GPUImageMovieWriter *movieWriter;
}
@property(nonatomic,strong)NSURL *movieURL;

/** 视频写入 */
//@property (nonatomic,strong) GPUImageMovieWriter *movieWriter;

/** 视频写入的地址URL */
@property (nonatomic,strong) NSURL *recordMovieURL;

/** 视频写入路径 */
@property (nonatomic,copy) NSString *writerMoviePath;

@end
