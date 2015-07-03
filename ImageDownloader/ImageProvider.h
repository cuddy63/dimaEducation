//
//  ImageProvider.h
//  ImageDownloader
//
//  Created by Стребков Константин on 29.06.15.
//  Copyright (c) 2015 SoundCuddy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ImageProvider,UIImage;

@protocol ImageProviderDelegate <NSObject>

- (void)imageProvider:(ImageProvider*)imageProvider
      didProvideImage:(UIImage*)image
           forURLPath:(NSString*)urlPath;

- (void)imageProvider:(ImageProvider *)imageProvider
     didFailWithError:(NSError*)error;

@end

@interface ImageProvider : NSObject

@property (weak, nonatomic) id <ImageProviderDelegate> delegate;

- (void)provideImageForUrlPath:(NSString*)urlPath;

@end
