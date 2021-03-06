//
//  NLVideoProcessViewController.m
//  NLGPUImageCamera
//
//  Created by kkmm on 2018/6/26.
//  Copyright © 2018年 kkmm. All rights reserved.
//

#import "VideoProcessViewController.h"
#import <AVKit/AVKit.h>
@interface VideoProcessViewController ()

@end

@implementation VideoProcessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	//	播放以及滤镜处理
	GPUImageView *gpuPlayView = [[GPUImageView alloc]initWithFrame:CGRectMake(0, 0, FUll_VIEW_WIDTH, FUll_VIEW_HEIGHT)];
	[self.view addSubview:gpuPlayView];
	gpuPlayView.backgroundColor = [UIColor blackColor];
	//	[self.view addSubview:gpuPlayView];不添加到可见视图上
	gpuMovieFile = [[GPUImageMovie alloc] initWithURL:self.movieURL];
	gpuMovieFile.runBenchmark = YES;
	gpuMovieFile.playAtActualSpeed = YES;
	filter = [[GPUImageSketchFilter alloc]init];

	[gpuMovieFile addTarget:filter];
	
	[filter addTarget:gpuPlayView];

	gpuMoviePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
	unlink([gpuMoviePath UTF8String]);
	gpuMovieURL = [NSURL fileURLWithPath:gpuMoviePath];
	
	AVAsset *asset = [AVAsset assetWithURL:self.movieURL];
	NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
	CGFloat width = FUll_VIEW_WIDTH;
	CGFloat height = FUll_VIEW_HEIGHT;
	CGAffineTransform movieWriterTransForm = CGAffineTransformMakeRotation(0);
	if([tracks count] > 0) {
		AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
		movieWriterTransForm = videoTrack.preferredTransform;//这里的矩阵有旋转角度，转换一下即可
		width =	videoTrack.naturalSize.width;
		height = videoTrack.naturalSize.height;
	}
	
	movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:gpuMovieURL size:CGSizeMake(width, height)];
	movieWriter.delegate = (id)self;
	movieWriter.transform = movieWriterTransForm;
	[filter addTarget:movieWriter];
	movieWriter.shouldPassthroughAudio = YES;
	gpuMovieFile.audioEncodingTarget = movieWriter;
	[gpuMovieFile enableSynchronizedEncodingUsingMovieWriter:movieWriter];
	
	[movieWriter startRecording];
	[gpuMovieFile startProcessing];
	
	gpuProgressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f
														target:self
													  selector:@selector(retrievingProgress)
													  userInfo:nil
													   repeats:YES];
	//		[audioPlayer play];
	
	__weak typeof(self) weakSelf = self;
	[movieWriter setCompletionBlock:^{
		[weakSelf stopRecord];
	}];
}

-(void)stopRecord{
	[filter removeTarget:movieWriter];
	[movieWriter finishRecording];
	dispatch_async(dispatch_get_main_queue(), ^{
		[NSObject toastMessage:@"好了"];
		[self playVideoWithURL:self->gpuMovieURL];
	});
}
-(void)playVideoWithURL:(NSURL *)url{
	AVPlayerViewController *_player = [[AVPlayerViewController alloc] init];
	_player.player = [[AVPlayer alloc] initWithURL:url];
	_player.videoGravity = AVLayerVideoGravityResize;
	[self presentViewController:_player animated:YES completion:nil];
	
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

- (void)retrievingProgress
{
	NSLog(@"%@",[NSString stringWithFormat:@"%d%%", (int)(gpuMovieFile.progress * 100)]);
	[NSObject toastMessage:[NSString stringWithFormat:@"%d%%", (int)(gpuMovieFile.progress * 100)]];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
