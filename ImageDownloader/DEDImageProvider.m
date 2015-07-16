//
//  ImageProvider.m
//  ImageDownloader
//
//  Created by Стребков Константин on 29.06.15.
//  Copyright (c) 2015 SoundCuddy. All rights reserved.
//

#import "DEDImageProvider.h"
#import <UIKit/UIKit.h>
#import "NSString+Hash.h"
#import "AFNetworking.h"

typedef NS_ENUM(NSUInteger, ImageDownloadErrorCode) {
    kInvalidURLErrorCode,
    kInvalidURLDataErrorCode,
    kInvalidImageDataCode
};

static NSString * const kImageProviderErrorDomain = @"ImageProviderErrorDomain";

@interface DEDImageProvider (){
    dispatch_queue_t downloadQueue;
}
@property (nonatomic, strong) NSCache *imageCache;
@property (nonatomic, strong) NSString* cachedFolderPath;
@property (nonatomic, strong) AFHTTPRequestOperationManager* manager;
@end

@implementation DEDImageProvider

#pragma mark - init&dealloc

- (instancetype)init{
    self = [super init];
    if (self) {
        downloadQueue = dispatch_queue_create("Image Download Queue", 0);
        _imageCache = [[NSCache alloc] init];
        _imageCache.totalCostLimit = 5 * 1024 * 1024;
        [self setupCachePath];
        self.manager = [AFHTTPRequestOperationManager manager];
    }
    return self;
}
#pragma mark - private

- (void) setupCachePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    _cachedFolderPath = [paths objectAtIndex:0];
    BOOL isDir = NO;
    NSError* error;
    if (![[NSFileManager defaultManager]fileExistsAtPath:_cachedFolderPath
                                             isDirectory:&isDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:_cachedFolderPath
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:&error];
    }
  
}
#pragma mark - public

- (UIImage*) ddownloadImageWithAFNFromURL: (NSString*) urlPath
                          withCompletion: (DEDImageProviderBlock) completionBlock {
    NSURL* url = [NSURL URLWithString:urlPath];
    __weak typeof(self) weakSelf = self;
    UIImage* cachedImage = [weakSelf imageFromCacheWithURLpath:urlPath];
    if (cachedImage) {
        if (completionBlock)
            completionBlock(cachedImage, nil);
        return cachedImage;
    }
    NSURLRequest* urlRequest = [[NSURLRequest alloc] initWithURL:url];
    
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc]initWithRequest:urlRequest];
    requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
    __block UIImage *image = [[UIImage alloc] init];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        image = responseObject;
        completionBlock(image, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(nil, error);
    }];
    [requestOperation start];
    return image;
}

- (UIImage*) downloadImageWithAFNFromURL: (NSString*) urlPath
                           withCompletion: (DEDImageProviderBlock) completionBlock {
    __weak typeof(self) weakSelf = self;
    UIImage* cachedImage = [weakSelf imageFromCacheWithURLpath:urlPath];
    if (cachedImage) {
        if (completionBlock)
            completionBlock(cachedImage, nil);
        return cachedImage;
    }
    __block UIImage* image = [[UIImage alloc] init];
    self.manager.responseSerializer = [AFImageResponseSerializer serializer];
    [self.manager GET:urlPath
           parameters:nil
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  image = responseObject;
                  completionBlock(image, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(nil, error);
    }];
    return image;
}

+ (instancetype)sharedInstance {
    static DEDImageProvider *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (UIImage*)imageFromCacheWithURLpath:(NSString*) urlPath {
    UIImage *result = nil;
    NSData *imageData = [_imageCache objectForKey:[NSURL URLWithString:urlPath]];
    
    if (imageData == nil){
        NSString *localFilePath = [self filePathForImageURLPath:urlPath];
        imageData = [[NSFileManager defaultManager] contentsAtPath:localFilePath];
    }
    
    if (imageData)
        result = [UIImage imageWithData:imageData];

    return result;
}

-(NSString*) filePathForImageURLPath: (NSString*) urlPath {
    NSString *appendingString = [NSString stringWithFormat:@"/%@",[urlPath hash_MD5]];
    NSString* localFilePath = [_cachedFolderPath stringByAppendingString:appendingString];
    return localFilePath;
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
        BOOL saved = [imageData writeToFile:[self filePathForImageURLPath:urlPath] atomically:YES];
        NSParameterAssert(saved);
        
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
