//
//  ImageProvider.h
//  ImageDownloader
//
//  Created by Стребков Константин on 29.06.15.
//  Copyright (c) 2015 SoundCuddy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DEDImageDisplayViewController.h"

@class UIImage, UIProgressView;

typedef void(^DEDImageProviderDownloadBlock)(UIImage *image, NSError *error);
typedef void(^DEDImageProviderProgressBlock)(CGFloat progress);


@interface DEDImageProvider : NSObject

@property (nonatomic, strong) NSString *cachedFolderPath;

+ (instancetype)sharedInstance;

- (void)downloadImageWithAFNFromURL:(NSString*)urlPath
                      progressBlock:(DEDImageProviderProgressBlock)progressBlock
                     withCompletion:(DEDImageProviderDownloadBlock)completionBlock;

- (NSString*)filePathForImageURLPath:(NSString*)urlPath;

- (void)cacheCleaning;

@end
