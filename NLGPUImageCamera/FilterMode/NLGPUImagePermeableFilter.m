//
//  NLGPUImagePermeableFilter.m
//  NLGPUImageCamera
//
//  Created by kkmm on 2018/6/21.
//  Copyright © 2018年 kkmm. All rights reserved.
//

#import "NLGPUImagePermeableFilter.h"

@implementation NLGPUImagePermeableFilter
- (id)init;
{
	if (!(self = [super init]))
	{
		return nil;
	}
	
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
	UIImage *image = [UIImage imageNamed:@"Permeable.png"];
#else
	NSImage *image = [NSImage imageNamed:@"Permeable.png"];
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
@end
