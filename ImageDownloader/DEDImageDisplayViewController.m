//
//  ViewController.m
//  ImageDownloader
//
//  Created by Стребков Константин on 29.06.15.
//  Copyright (c) 2015 SoundCuddy. All rights reserved.
//

#import "DEDImageDisplayViewController.h"
#import "ImageProvider.h"

static const NSTimeInterval kImageFadeInAnimationTime = 0.3;

@interface DEDImageDisplayViewController () <ImageProviderDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) ImageProvider *imageProvider;
@property (strong, nonatomic) NSString      *imageURLPath;


@end

@implementation DEDImageDisplayViewController

- (void)setImageURLPath:(NSString *)imageUrlPath{
    if (_imageURLPath != imageUrlPath && ![_imageURLPath isEqualToString:imageUrlPath]) {
        _imageURLPath = imageUrlPath;
        if (self.isViewLoaded)
            [self.imageProvider provideImageForUrlPath:self.imageURLPath];
    }
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageProvider = [[ImageProvider alloc] init];
    self.imageProvider.delegate = self;
    
    if (self.imageURLPath)
        [self.imageProvider provideImageForUrlPath:self.imageURLPath];
}


#pragma mark - ImageProviderDelegate

- (void)imageProvider:(ImageProvider*)imageProvider
      didProvideImage:(UIImage*)image
           forURLPath:(NSString*)urlPath{

    self.imageView.image = image;
    [self animateImageAppearance];
}


- (void)imageProvider:(ImageProvider *)imageProvider didFailWithError:(NSError *)error{
    [[[UIAlertView alloc] initWithTitle:@"Download failed"
                               message:error.localizedDescription
                              delegate:nil
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil] show];
    
}



#pragma mark - private

- (void)animateImageAppearance{
    CATransition *transition = [CATransition animation];
    transition.duration = kImageFadeInAnimationTime;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [self.imageView.layer addAnimation:transition forKey:nil];
}

@end
