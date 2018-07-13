//
//  NLGPUImage02Filter.m
//  NLGPUImageCamera
//
//  Created by kkmm on 2018/6/20.
//  Copyright © 2018年 kkmm. All rights reserved.
//

#import "NLGPUImage02Filter.h"

@implementation NLGPUImage02Filter
- (id)init;
{
	if (!(self = [super init]))
	{
		return nil;
	}
	
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
	UIImage *image = [UIImage imageNamed:@"02.png"];
#else
	NSImage *image = [NSImage imageNamed:@"02.png"];
#endif
	
	NSAssert(image, @"To use GPUImageAmatorkaFilter you need to add lookup_amatorka.png from GPUImage/framework/Resources to your application bundle.");
	
	lookupImageSource = [[GPUImagePicture alloc] initWithImage:image];
	GPUImageLookupFilter *lookupFilter = [[GPUImageLookupFilter alloc] init];
	[self addFilter:lookupFilter];
	
	[lookupImageSource addTarget:lookupFilter atTextureLocation:1];
	[lookupImageSource processImage];
	
	self.initialFilters = [NSArray arrayWithObjects:lookupFilter, nil];
	self.terminalFilter = lookupFilter;
	
	return self;
}

#pragma mark -
#pragma mark Accessors

@end
