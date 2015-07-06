//
//  ImageProvider.h
//  ImageDownloader
//
//  Created by Стребков Константин on 29.06.15.
//  Copyright (c) 2015 SoundCuddy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage;

typedef void(^DEDImageProviderBlock)(UIImage *image, NSError *error);


@interface ImageProvider : NSObject

+ (instancetype)sharedInstance;

- (void)provideImageForUrlPath:(NSString*)urlPath
               completionBlock:(DEDImageProviderBlock)completion;

@end
