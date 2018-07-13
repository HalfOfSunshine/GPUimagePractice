//
//  ViewController.m
//  NLGPUImageCamera
//
//  Created by kkmm on 2018/6/7.
//  Copyright © 2018年 kkmm. All rights reserved.
//

#import "ViewController.h"
#import "FilterCameraViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "VideoProcessViewController.h"
#import "VideoPreviewPlayerViewController.h"
#import <AVKit/AVKit.h>
//#import "SimpleVideoFileFilterViewController.h"
@interface ViewController ()<UIImagePickerControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self.view setBackgroundColor:[UIColor lightGrayColor]];
	UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-60, self.view.frame.size.height/4-60, 120, 120)];
	btn.layer.cornerRadius = 60;
	[btn setTitle:@"打开摄像头" forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(openCamera) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:btn];
	
	UIButton *btn2 = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-60, self.view.frame.size.height/4+60, 120, 120)];
	btn2.layer.cornerRadius = 60;
	[btn2 setTitle:@"选择本地视频" forState:UIControlStateNormal];
	[btn2 addTarget:self action:@selector(chooseVideo) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:btn2];
	
	
	UIButton *btn3 = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-60, self.view.frame.size.height/4+190, 120, 120)];
	btn3.layer.cornerRadius = 60;
	[btn3 setTitle:@"预览视频" forState:UIControlStateNormal];
	[btn3 addTarget:self action:@selector(DemoProcess) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:btn3];
}

-(void)openCamera{
//	第一帧黑屏的问题尽量不要用网上提供的修改gpuMovieWriter类的方法，会导致本地视频合成滤镜不可用。如果不需要本地视频加滤镜请无视。
	FilterCameraViewController *filterCameraViewController = [[FilterCameraViewController alloc]init];
	[self.navigationController pushViewController:filterCameraViewController animated:YES];
}

-(void)chooseVideo{
	 NSURL *sampleURL = [[NSBundle mainBundle] URLForResource:@"sample_iPod" withExtension:@"m4v"];
	VideoProcessViewController *videoVC = [[VideoProcessViewController alloc]init];
	videoVC.title = @"视频编辑";
	videoVC.movieURL = sampleURL;
	[self.navigationController pushViewController:videoVC animated:YES];
}

-(void)DemoProcess{
//	此方式预览加上录制会有一些问题，建议录制跟预览分开。一定要一起用的话，预览的时候用VideoProcessViewController，另外加音频，这样问题也很多。
	NSURL *sampleURL = [[NSBundle mainBundle] URLForResource:@"sample_iPod" withExtension:@"m4v"];
	VideoPreviewPlayerViewController *vc = [[VideoPreviewPlayerViewController alloc]init];
	vc.title = @"视频预览";
	vc.movieURL = sampleURL;
	[self.navigationController pushViewController:vc animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
	NSLog(@"选好了");
	self.movieURL = [info valueForKey:@"UIImagePickerControllerMediaURL"];
	[picker dismissViewControllerAnimated:YES completion:nil];
	VideoProcessViewController *videoVC = [[VideoProcessViewController alloc]init];
	videoVC.title = @"视频编辑";
	videoVC.movieURL = self.movieURL;
	[self.navigationController pushViewController:videoVC animated:YES];
}

-(void)playVideoWithURL:(NSURL *)url{
	AVPlayerViewController *_player = [[AVPlayerViewController alloc] init];
	_player.player = [[AVPlayer alloc] initWithURL:url];
	_player.videoGravity = AVLayerVideoGravityResize;
	[self presentViewController:_player animated:YES completion:nil];
	
}
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
