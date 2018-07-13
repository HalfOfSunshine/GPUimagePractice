//
//  NLGPUImagePermeableFilter.h
//  NLGPUImageCamera
//
//  Created by kkmm on 2018/6/21.
//  Copyright © 2018年 kkmm. All rights reserved.
//

#import "GPUImageFilterGroup.h"

@interface NLGPUImagePermeableFilter : GPUImageFilterGroup
{
	GPUImagePicture *lookupImageSource;
}
@end
