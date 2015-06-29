//
//  ImageProvider.m
//  ImageDownloader
//
//  Created by Стребков Константин on 29.06.15.
//  Copyright (c) 2015 SoundCuddy. All rights reserved.
//

#import "ImageProvider.h"
#import <UIKit/UIKit.h>

@interface ImageProvider (){
    dispatch_queue_t downloadQueue;
}

@end

@implementation ImageProvider

- (instancetype)init{
    self = [super init];
    if (self) {
        downloadQueue = dispatch_queue_create("Image Download Queue", 0);
    }
    return self;
}

- (void)provideImageForUrlPath:(NSString*)urlPath{
    __weak typeof(self) weakSelf = self;
    dispatch_async(downloadQueue,^
    {
        NSURL   *imageURL   = [NSURL URLWithString:urlPath];
        NSData  *imageData  = [NSData dataWithContentsOfURL:imageURL];
        UIImage *image      = [UIImage imageWithData:imageData];
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [weakSelf.delegate imageProvider:weakSelf didProvideImage:image forURLPath:urlPath];
        });
    });
}

@end
