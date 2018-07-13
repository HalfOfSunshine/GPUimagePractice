//
//  NLFilterCameraViewController.m
//  NLGPUImageCamera
//
//  Created by kkmm on 2018/6/7.
//  Copyright © 2018年 kkmm. All rights reserved.
//

#import "FilterCameraViewController.h"
#import "NLGPUImage02Filter.h"
#import "NLGPUImageBluesFilter.h"
#import "NLGPUImageRetroFilter.h"
#import "NLGPUImageDarkRedFilter.h"
#import "NLGPUImagePermeableFilter.h"
#import "NLGPUImageGrayOrangeFilter.h"

#import <AVKit/AVKit.h>
@interface FilterCameraViewController ()<GPUImageVideoCameraDelegate>{
	UIButton *videoBtn;
	UIButton *photoBtn;
	UIButton *filterSelectBtn;
}
/** 视频预览 */
@property (nonatomic,strong) AVPlayerViewController *player;

/** 照片预览 */
@property (nonatomic,strong) UIImageView *PhotoPreView;


@property (nonatomic,strong) NSString *filePath;

/** 摄像头 */
@property(nonatomic, strong) GPUImageStillCamera *filterCamera;

/** 视频输出视图 */
@property (nonatomic, strong) GPUImageView *filterView;

/** 视频写入 */
@property (nonatomic,strong) GPUImageMovieWriter *movieWriter;

/** 视频写入的地址URL */

/** 视频写入路径 */
@property (nonatomic,copy) NSString *moviePath;

/** 压缩成功后的视频路径 */
@property (nonatomic,copy) NSString *resultPath;

/** 视频时长 */
@property (nonatomic,assign) int seconds;

/** 系统计时器 */
@property (nonatomic,strong) NSTimer *recordTimer;

/** 计时器常量 */
@property (nonatomic,assign) int recordSecond;


@end

@implementation FilterCameraViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	[self.navigationController setNavigationBarHidden:YES];
	self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
	[self setupCaptureSession];
	[self setupUI];

}
-(void)viewDidDisappear:(BOOL)animated{
	if (_filterCamera) {[_filterCamera stopCameraCapture];}
}
-(void)viewWillAppear:(BOOL)animated{
	if (_filterCamera) {[_filterCamera startCameraCapture];}
}

#pragma mark - 打开摄像机
- (void)setupCaptureSession
{
	if (!_filterCamera) {
		_filterCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetiFrame960x540 cameraPosition:AVCaptureDevicePositionFront];
		_filterCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
		_filterCamera.delegate = (id)self;
		_filterCamera.horizontallyMirrorFrontFacingCamera = YES;

		 //防止允许声音通过的情况下,第一帧黑屏
		[_filterCamera addAudioInputsAndOutputs];
	}
	
	if (!self.filterView) {
		self.filterView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, FUll_VIEW_WIDTH, FUll_VIEW_HEIGHT)];
		self.filterView.center = self.view.center;
		self.filterView.fillMode = kGPUImageFillModeStretch;
		[self.view addSubview:self.filterView];
		
		GPUImageBoxBlurFilter *beautifyFilter = [[GPUImageBoxBlurFilter alloc] init];
		beautifyFilter.blurRadiusInPixels = 0;
		[beautifyFilter addTarget:self.filterView];
		[_filterCamera addTarget:beautifyFilter];
		NSLog(@"相机的targets%@",_filterCamera.targets);
	}
	[_filterCamera startCameraCapture];
}

-(void)setupUI{
	[self createFilterSelector];
	
	videoBtn = [[UIButton alloc]initWithFrame:CGRectMake(FUll_VIEW_WIDTH/2-50, FUll_VIEW_HEIGHT -110, 100, 100)];
	videoBtn.layer.cornerRadius = 50;
	videoBtn.alpha = 0.5;
	[videoBtn setTitle:@"拍视频" forState:UIControlStateNormal];
	videoBtn.backgroundColor = [UIColor blueColor];
	[videoBtn addTarget:self action:@selector(startRecordVideo) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:videoBtn];
	[self.view bringSubviewToFront:videoBtn];
	
	photoBtn = [[UIButton alloc]initWithFrame:CGRectMake(FUll_VIEW_WIDTH/2-50, FUll_VIEW_HEIGHT -220, 100, 100)];
	photoBtn.layer.cornerRadius = 50;
	photoBtn.alpha = 0.5;
	[photoBtn setTitle:@"拍照片" forState:UIControlStateNormal];
	photoBtn.backgroundColor = [UIColor blueColor];
	[photoBtn addTarget:self action:@selector(capturePhoto) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:photoBtn];
	[self.view bringSubviewToFront:photoBtn];
	
	[self.view addSubview:self.PhotoPreView];
	[self.view bringSubviewToFront:self.PhotoPreView];
}

#pragma mark - 滤镜选择项
-(void)createFilterSelector{
	CGFloat width = 120, height = 50, Xinterval = 10 ,Yinterval =10;
	//	 第一行
	[self createFilterBtnWithTitle:@"通透" frame:CGRectMake(FUll_VIEW_WIDTH/2-width/2 - Xinterval - width, 30, width, height) targetName:@selector(Permeable)];
	[self createFilterBtnWithTitle:@"蓝调" frame:CGRectMake(FUll_VIEW_WIDTH/2-width/2, 30, width, height) targetName:@selector(Blues)];
	[self createFilterBtnWithTitle:@"复古" frame:CGRectMake(FUll_VIEW_WIDTH/2+width/2 + Xinterval, 30, width, height) targetName:@selector(Retro)];
	//	第二行
	[self createFilterBtnWithTitle:@"removeAllTarget" frame:CGRectMake(FUll_VIEW_WIDTH/2-width/2, 30+height+Yinterval, width, height) targetName:@selector(removeAllTarget)];
	[self createFilterBtnWithTitle:@"灰橙" frame:CGRectMake(FUll_VIEW_WIDTH/2-width/2 - Xinterval - width, 30+height+Yinterval, width, height) targetName:@selector(GrayOrange)];
	[self createFilterBtnWithTitle:@"暗红" frame:CGRectMake(FUll_VIEW_WIDTH/2+width/2 + Xinterval, 30+height+Yinterval, width, height) targetName:@selector(DarkRed)];
	
//	第三行
	[self createFilterBtnWithTitle:@"Sketch" frame:CGRectMake(FUll_VIEW_WIDTH/2-width/2 - Xinterval - width, 30+2*height+2*Yinterval, width, height) targetName:@selector(Sketch)];
	
	[self createFilterBtnWithTitle:@"Sepia" frame:CGRectMake(FUll_VIEW_WIDTH/2-width/2, 30+2*height+2*Yinterval, width, height) targetName:@selector(Sepia)];
	
	[self createFilterBtnWithTitle:@"mixFilter" frame:CGRectMake(FUll_VIEW_WIDTH/2+width/2 + Xinterval, 30+2*height+2*Yinterval, width, height) targetName:@selector(mixFilter)];

}

-(void)createFilterBtnWithTitle:(NSString *)title frame:(CGRect)rect targetName:(SEL)selector{
	UIButton *btn = [[UIButton alloc]initWithFrame:rect];
	btn.layer.cornerRadius = 5;
	btn.alpha = 0.5;
	[btn setTitle:title forState:UIControlStateNormal];
	btn.backgroundColor = [UIColor lightGrayColor];
	[btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:btn];
	[self.view bringSubviewToFront:btn];
}

#pragma mark - 各种滤镜
-(void)DarkRed{
	[NSObject toastMessage:@"按了DarkRed"];
	[_filterCamera removeAllTargets];
	

	NLGPUImageDarkRedFilter *beautifyFilter = [[NLGPUImageDarkRedFilter alloc] init];
	[beautifyFilter addTarget:self.filterView];
	[_filterCamera addTarget:beautifyFilter];
	NSLog(@"相机的targets%@",_filterCamera.targets);

}
-(void)GrayOrange{
	[NSObject toastMessage:@"按了GrayOrange"];
	[_filterCamera removeAllTargets];

	NLGPUImageGrayOrangeFilter *beautifyFilter = [[NLGPUImageGrayOrangeFilter alloc] init];
	[beautifyFilter addTarget:self.filterView];
	[_filterCamera addTarget:beautifyFilter];
	NSLog(@"相机的targets%@",_filterCamera.targets);
	
}

-(void)Blues{
	[NSObject toastMessage:@"按了Blues"];
	[_filterCamera removeAllTargets];
	NLGPUImageBluesFilter *beautifyFilter = [[NLGPUImageBluesFilter alloc] init];
	[beautifyFilter addTarget:self.filterView];
	[_filterCamera addTarget:beautifyFilter];
	NSLog(@"相机的targets%@",_filterCamera.targets);
}

-(void)Permeable{
	[NSObject toastMessage:@"按了Permeable"];
	[_filterCamera removeAllTargets];
	NLGPUImagePermeableFilter *beautifyFilter = [[NLGPUImagePermeableFilter alloc] init];
	[beautifyFilter addTarget:self.filterView];
	[_filterCamera addTarget:beautifyFilter];
	NSLog(@"相机的targets%@",_filterCamera.targets);

}

-(void)Retro{
	[NSObject toastMessage:@"按了Retro"];
	[_filterCamera removeAllTargets];
	NLGPUImageRetroFilter *beautifyFilter = [[NLGPUImageRetroFilter alloc] init];
	[beautifyFilter addTarget:self.filterView];
	[_filterCamera addTarget:beautifyFilter];
	NSLog(@"相机的targets%@",_filterCamera.targets);

}

-(void)Sketch{
	[NSObject toastMessage:@"按了Sketch"];
	[_filterCamera removeAllTargets];
	GPUImageSketchFilter *beautifyFilter = [[GPUImageSketchFilter alloc] init];
	[beautifyFilter addTarget:self.filterView];
	[_filterCamera addTarget:beautifyFilter];
	NSLog(@"相机的targets%@",_filterCamera.targets);
	
}

-(void)Sepia{
	[NSObject toastMessage:@"按了Sepia"];
	[_filterCamera removeAllTargets];
	GPUImageSepiaFilter *beautifyFilter = [[GPUImageSepiaFilter alloc] init];
	[beautifyFilter addTarget:self.filterView];
	[_filterCamera addTarget:beautifyFilter];
	NSLog(@"相机的targets%@",_filterCamera.targets);
}

-(void)mixFilter{
	[NSObject toastMessage:@"按了mixFilter"];
	[_filterCamera removeAllTargets];

	GPUImageSketchFilter *disFilter = [[GPUImageSketchFilter alloc] init];
	//褐色
	GPUImageSepiaFilter* sepiaFilter = [[GPUImageSepiaFilter alloc] init];
	
	GPUImageFilterGroup	*filterGroup = [[GPUImageFilterGroup alloc] init];
	[filterGroup addFilter:disFilter];
	[filterGroup addFilter:sepiaFilter];
	
	//先后顺序
	[disFilter addTarget:sepiaFilter];
	
	//开始的滤镜
	[filterGroup setInitialFilters:[NSArray arrayWithObject:disFilter]];
	[filterGroup setTerminalFilter:sepiaFilter];
	
	[filterGroup addTarget:self.filterView];
	[_filterCamera addTarget:filterGroup];
	
//	[filterGroup addTarget:m_movieWriter];
}
-(void)removeAllTarget{
	[NSObject toastMessage:@"按了removeAllTarget"];
	[_filterCamera removeAllTargets];
	GPUImageBoxBlurFilter *beautifyFilter = [[GPUImageBoxBlurFilter alloc] init];
	beautifyFilter.blurRadiusInPixels = 0;
	[beautifyFilter addTarget:self.filterView];
	[_filterCamera addTarget:beautifyFilter];
	NSLog(@"相机的targets%@",_filterCamera.targets);

}
#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
// Delegate routine that is called when a sample buffer was written
- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
}

#pragma mark - 拍照片，写入
-(void)capturePhoto{
	__weak typeof(self) weakself = self;
	[weakself.filterCamera capturePhotoAsImageProcessedUpToFilter:self.filterCamera.targets[0] withCompletionHandler:^(UIImage *processedImage, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.PhotoPreView setImage:processedImage];
			self.PhotoPreView.alpha = 1;
			[UIView animateWithDuration:2.0 animations:^{
				self.PhotoPreView.alpha = 0;
			}];
		});
	}];
}

#pragma mark - 拍视频，写入
// 开始录制
-(void)startRecordVideo{
	
	NSString *defultPath = [self getVideoPathCache];
	self.moviePath = [defultPath stringByAppendingPathComponent:[self getVideoNameWithType:@"mp4"]];
	// 录制路径
	self.movieURL = [NSURL fileURLWithPath:self.moviePath];
	//如果已经存在文件，AVAssetWriter会有异常，删除旧文件
	unlink([self.moviePath UTF8String]);
	
	self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:self.movieURL size:CGSizeMake(480.0, 640.0)];
	self.movieWriter.encodingLiveVideo = YES;
	self.movieWriter.shouldPassthroughAudio = YES;
	[self.filterCamera.targets[0] addTarget:self.movieWriter];
	self.filterCamera.audioEncodingTarget = self.movieWriter;
	// 开始录制
	[self.movieWriter startRecording];
	
	[NSObject toastMessage:@"开始录制"];
	[self.recordTimer setFireDate:[NSDate distantPast]];
	[self.recordTimer fire];
}

// 获取视频地址
-(NSString *)getVideoPathCache {
	NSString *videoCache = [NSTemporaryDirectory() stringByAppendingString:@"videos"];
	BOOL isDir = NO;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL existed = [fileManager fileExistsAtPath:videoCache isDirectory:&isDir];
	if (!existed) {
		[fileManager createDirectoryAtPath:videoCache withIntermediateDirectories:YES attributes:nil error:nil];
	}
	return videoCache;
}

// 获取视频名称
-(NSString *)getVideoNameWithType:(NSString *)fileType {
	
	NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"HHmmss"];
	NSDate *nowDate = [NSDate dateWithTimeIntervalSince1970:now];
	NSString *timeStr = [formatter stringFromDate:nowDate];
	NSString *fileName = [NSString stringWithFormat:@"video_%@.%@",timeStr,fileType];
	return fileName;
}

// 结束录制
-(void)endRecording {
	
	if ([self.filterCamera.captureSession isRunning]) {
		
		[self.recordTimer invalidate];
		self.recordTimer = nil;
		__weak typeof(self) weakSelf = self;
		[self.movieWriter finishRecording];
		[self.filterCamera.targets[0] removeTarget:self.movieWriter];
		self.filterCamera.audioEncodingTarget = nil;
		UIImage	*videoCover = [self thumbnailImageForVideo:self.movieURL atTime:0];

		if (self.recordSecond > 5.0) {
			
			// 清除录制的视频
			
		}else {
			
			// 压缩中...
			self.recordSecond = 0;
			[NSObject toastMessage:@"压缩中"];
			
			// 压缩
			[weakSelf compressVideoWithUrl:self.movieURL compressionType:AVAssetExportPresetMediumQuality filePath:^(NSString *resultPath, float memorySize, NSString *videoImagePath, int seconds) {
				
				
				NSData *data = [NSData dataWithContentsOfFile:resultPath];
				CGFloat totalTime = (CGFloat)data.length / 1024 / 1024;
				
				// 压缩完回调
				[NSObject toastMessage:[NSString stringWithFormat:@" 录制完毕，时长%f  路径：%@",totalTime,resultPath]];
				
				self.filePath = resultPath;
				
//				回主线程操作UI
				[self saveVideo:resultPath];
			
				
			}];
		}
	}
}

- (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
	
	AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
	NSParameterAssert(asset);
	AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
	assetImageGenerator.appliesPreferredTrackTransform = YES;
	assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
	
	CGImageRef thumbnailImageRef = NULL;
	CFTimeInterval thumbnailImageTime = time;
	NSError *thumbnailImageGenerationError = nil;
	thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];
	
	if(!thumbnailImageRef)
		NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
	
	UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
	
	return thumbnailImage;
}

-(void)playVideo {
	_player = [[AVPlayerViewController alloc] init];
	_player.player = [[AVPlayer alloc] initWithURL:[NSURL fileURLWithPath:_filePath]];
	_player.videoGravity = AVLayerVideoGravityResize;
	[self presentViewController:_player animated:YES completion:nil];
}

// 暂停
-(void)pauseRecording {
	
	if ([_filterCamera.captureSession isRunning]) {
		[self.recordTimer invalidate];
		self.recordTimer = nil;
		[_filterCamera pauseCameraCapture];
	}
	
}

// 恢复
-(void)resumeRecording {
	
	[_filterCamera resumeCameraCapture];
	[self.recordTimer setFireDate:[NSDate distantPast]];
	[self.recordTimer fire];
}
// 压缩视频
-(void)compressVideoWithUrl:(NSURL *)url compressionType:(NSString *)type filePath:(void(^)(NSString *resultPath,float memorySize,NSString * videoImagePath,int seconds))resultBlock {
	
	NSString *resultPath;
	
	
	// 视频压缩前大小
	NSData *data = [NSData dataWithContentsOfURL:url];
	CGFloat totalSize = (float)data.length / 1024 / 1024;
	NSLog(@"压缩前大小：%.2fM",totalSize);
	AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
	
	CMTime time = [avAsset duration];
	
	// 视频时长
	int seconds = ceil(time.value / time.timescale);
	
	NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
	if ([compatiblePresets containsObject:type]) {
		
		//压缩质量为中等质量：AVAssetExportPresetMediumQuality
		AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
		
		// 用时间给文件命名 防止存储被覆盖
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
		
		// 若压缩路径不存在重新创建
		NSFileManager *manager = [NSFileManager defaultManager];
		BOOL isExist = [manager fileExistsAtPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/CompressionVideoField"]];
		if (!isExist) {
			[manager createDirectoryAtPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/CompressionVideoField"] withIntermediateDirectories:YES attributes:nil error:nil];
		}
		resultPath = [[NSHomeDirectory() stringByAppendingFormat:@"/Documents/CompressionVideoField"] stringByAppendingPathComponent:[NSString stringWithFormat:@"user%outputVideo-%@.mp4",arc4random_uniform(10000),[formatter stringFromDate:[NSDate date]]]];
		
		session.outputURL = [NSURL fileURLWithPath:resultPath];
		session.outputFileType = AVFileTypeMPEG4;
		session.shouldOptimizeForNetworkUse = YES;
//		开始压缩
		[session exportAsynchronouslyWithCompletionHandler:^{
//			进度
			NSLog(@"%lf", session.progress);
//			状态
			switch (session.status) {
				case AVAssetExportSessionStatusUnknown:
					[NSObject toastMessage:@"压缩状态：AVAssetExportSessionStatusUnknown"];
					break;
				case AVAssetExportSessionStatusWaiting:
					[NSObject toastMessage:@"压缩状态：AVAssetExportSessionStatusWaiting"];

					break;
				case AVAssetExportSessionStatusExporting:
					[NSObject toastMessage:@"压缩状态：AVAssetExportSessionStatusExporting"];

					break;
				case AVAssetExportSessionStatusCancelled:
					[NSObject toastMessage:@"压缩状态：AVAssetExportSessionStatusCancelled"];

					break;
				case AVAssetExportSessionStatusFailed:
				{
					[NSObject toastMessage:@"压缩失败"];
					
				}
					break;
				case AVAssetExportSessionStatusCompleted:{
					
					NSData *data = [NSData dataWithContentsOfFile:resultPath];
					// 压缩过后的大小
					float compressedSize = (float)data.length / 1024 / 1024;
					resultBlock(resultPath,compressedSize,@"",seconds);
					NSLog(@"压缩后大小：%.2f",compressedSize);
				}
				default:
					break;
			}
		}];
	}
}

-(void)compressProcessC:(AVAssetExportSession *)session{
	
}
- (void)saveVideo:(NSString *)videoPath{
	
	if (videoPath) {
		NSURL *url = [NSURL URLWithString:videoPath];
		BOOL compatible = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([url path]);
		if (compatible)
		{
			//保存相册核心代码
			UISaveVideoAtPathToSavedPhotosAlbum([url path], self, @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:), nil);
		}
	}
}


//保存视频完成之后的回调
- (void) savedPhotoImage:(UIImage*)image didFinishSavingWithError: (NSError *)error contextInfo: (void *)contextInfo {
	if (error) {
		NSLog(@"保存视频失败%@", error.localizedDescription);
		[NSObject toastMessage:@"保存视频失败"];
	}
	else {
		NSLog(@"保存视频成功");
		
		[NSObject toastMessage:@"保存视频成功"];
		dispatch_async(dispatch_get_main_queue(), ^{
			[self playVideo];
		});

	}
}

#pragma - mark 懒加载
// 计时器
-(NSTimer *)recordTimer {
	if (!_recordTimer) {
		_recordTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateWithTime) userInfo:nil repeats:YES];
	}
	return _recordTimer;
}

// 超过最大录制时长结束录制
-(void)updateWithTime {
	
	self.recordSecond++;
	if (self.recordSecond >= 5.0) {
		[self endRecording];
	}
	
}

-(UIImageView *)PhotoPreView{
	if (!_PhotoPreView) {
		_PhotoPreView = [[UIImageView alloc]initWithFrame:CGRectMake(FUll_VIEW_WIDTH/4*3, 0, FUll_VIEW_WIDTH/4, FUll_VIEW_HEIGHT/4)];
		_PhotoPreView.alpha = 0;
	}
	return _PhotoPreView;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
