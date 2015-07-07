//
//  ImageProvider.m
//  ImageDownloader
//
//  Created by Стребков Константин on 29.06.15.
//  Copyright (c) 2015 SoundCuddy. All rights reserved.
//

#import "ImageProvider.h"
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ImageDownloadErrorCode) {
    kInvalidURLErrorCode,
    kInvalidURLDataErrorCode,
    kInvalidImageDataCode
};

static NSString * const kImageProviderErrorDomain = @"ImageProviderErrorDomain";

@interface ImageProvider (){
    dispatch_queue_t downloadQueue;
}
@property (strong, nonatomic) NSCache *imageCache;

@end

@implementation ImageProvider

#pragma mark - init&dealloc

- (instancetype)init{
    self = [super init];
    if (self) {
        downloadQueue = dispatch_queue_create("Image Download Queue", 0);
        _imageCache = [[NSCache alloc] init];
        _imageCache.totalCostLimit = 5 * 1024 * 1024;
    }
    return self;
}

#pragma mark - public

+ (instancetype)sharedInstance {
    static ImageProvider *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (UIImage*)imageFromCacheWithURLpath:(NSString*) urlPath {
    UIImage *result = nil;
    NSData *imageData = [_imageCache objectForKey:[NSURL URLWithString:urlPath]];
    if (imageData)
        result = [UIImage imageWithData:imageData];
    
    return result;
}

- (void)provideImageForUrlPath:(NSString*)urlPath
               completionBlock:(DEDImageProviderBlock)completion
{
    
    urlPath = [urlPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL   *imageURL   = [NSURL URLWithString:urlPath];
    if (imageURL == nil || imageURL.absoluteString.length == 0) {
        [self finishDownloadWithErrorCode:kInvalidURLErrorCode completion:completion];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    UIImage* cachedImage = [weakSelf imageFromCacheWithURLpath:urlPath];
    if (cachedImage) {
        if (completion)
            completion(cachedImage, nil);
        return;
    }
    dispatch_async(downloadQueue,^{
        NSData  *imageData  = [NSData dataWithContentsOfURL:imageURL];
        if (imageData == nil) {
            [weakSelf finishDownloadWithErrorCode:kInvalidURLDataErrorCode completion:completion];
            return;
        }
        
        UIImage *image      = [UIImage imageWithData:imageData];
        if (image == nil) {
            [self finishDownloadWithErrorCode:kInvalidImageDataCode completion:completion];
            return;
        }
        [_imageCache setObject:imageData forKey:imageURL];
        if (completion)
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(image, nil);
            });
    });
}

- (void)finishDownloadWithErrorCode:(ImageDownloadErrorCode)errorCode completion:(DEDImageProviderBlock)completion{
    if (completion == nil)
        return;
    
    if (![NSThread isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
           [self finishDownloadWithErrorCode:errorCode completion:completion];
        });
        return;
    }
    
    NSString *localizedDescriptionString = nil;
    
    switch (errorCode) {
        case kInvalidURLErrorCode:
            localizedDescriptionString = @"Invalid URL";
            break;
        case kInvalidURLDataErrorCode:
            localizedDescriptionString = @"Unable to access data for URL";
            break;
        case kInvalidImageDataCode:
            localizedDescriptionString = @"Invalid image data for URL";
            break;
    }
    
    NSError * error = [NSError errorWithDomain:kImageProviderErrorDomain
                                          code:errorCode
                                      userInfo:@{ NSLocalizedDescriptionKey : localizedDescriptionString}];
    
    completion(nil, error);
}


@end
