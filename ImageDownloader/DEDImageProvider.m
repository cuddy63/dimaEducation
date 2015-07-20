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
@property (nonatomic, strong) AFHTTPRequestOperationManager* manager;
@property (nonatomic, strong) NSString *filePath;

@end

@implementation DEDImageProvider

#pragma mark - init&dealloc

- (instancetype)initInternal{
    self = [super init];
    if (self) {
        downloadQueue = dispatch_queue_create("Image Download Queue", 0);
        _imageCache = [[NSCache alloc] init];
        _imageCache.totalCostLimit = 5 * 1024 * 1024;
        [self setupCachePath];
        self.manager = [AFHTTPRequestOperationManager manager];
        self.manager.operationQueue.maxConcurrentOperationCount = 2;
        [self cacheCleaning];
    }
    return self;
}

- (instancetype)init{
    NSParameterAssert(NO);
    return nil;
}

#pragma mark - private

- (void) setupCachePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    _cachedFolderPath = [paths firstObject];
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

- (void)cacheCleaning {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *directory = self.cachedFolderPath;
    
    for (NSString *path in [fm contentsOfDirectoryAtPath:directory error:nil]) {
        [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", directory, path] error:nil];
    }
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

#pragma mark - public

- (void)downloadImageWithAFNFromURL:(NSString*)urlPath
                      progressBlock:(DEDImageProviderProgressBlock)progressBlock
                     withCompletion:(DEDImageProviderDownloadBlock)completionBlock{
    __weak typeof(self) weakSelf = self;
    UIImage* cachedImage = [weakSelf imageFromCacheWithURLpath:urlPath];
    if (cachedImage)
    {
        if (completionBlock)
            completionBlock(cachedImage, nil);
        return;
    }
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlPath]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSData* responseData) {
        UIImage *image = [UIImage imageWithData:responseData];
        if (image) {
            [_imageCache setObject:responseData forKey:urlPath];
            BOOL saved = [responseData writeToFile:[self filePathForImageURLPath:urlPath] atomically:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(image, nil);
            });
            NSParameterAssert(saved);
        } else {
            [weakSelf finishDownloadWithErrorCode:kInvalidImageDataCode completion:completionBlock];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(nil, error);
        });
    }];
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        float downloadProgress = (float)totalBytesRead / (float)totalBytesExpectedToRead;
        if (progressBlock)
            progressBlock(downloadProgress);
    }];
    operation.completionQueue = downloadQueue;
    [self.manager.operationQueue addOperation:operation];
}


+ (instancetype)sharedInstance {
    static DEDImageProvider *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] initInternal];
    });
    return sharedInstance;
}


-(NSString*) filePathForImageURLPath: (NSString*) urlPath {
    NSString *appendingString = [NSString stringWithFormat:@"/%@",[urlPath hash_MD5]];
    NSString* localFilePath = [_cachedFolderPath stringByAppendingString:appendingString];
    self.filePath = localFilePath;
    return localFilePath;
}



- (void)finishDownloadWithErrorCode:(ImageDownloadErrorCode)errorCode completion:(DEDImageProviderDownloadBlock)completion{
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

#pragma mark - old methods

/* - (void)provideImageForUrlPath:(NSString*)urlPath
               completionBlock:(DEDImageProviderDownloadBlock)completion
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
*/
@end
