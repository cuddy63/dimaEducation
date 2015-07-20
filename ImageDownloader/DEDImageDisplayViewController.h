//
//  ViewController.h
//  ImageDownloader
//
//  Created by Стребков Константин on 29.06.15.
//  Copyright (c) 2015 SoundCuddy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DEDImageDisplayViewController : UIViewController

@property (strong, nonatomic) NSString      *imageURLPath;

- (void)setImageURLPath:(NSString*)imageUrlPath;

@end

