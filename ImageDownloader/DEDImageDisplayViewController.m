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

@interface DEDImageDisplayViewController ()

@property (weak,   nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) NSString      *imageURLPath;

@end

@implementation DEDImageDisplayViewController

- (void)setImageURLPath:(NSString *)imageUrlPath{
    if (_imageURLPath != imageUrlPath && ![_imageURLPath isEqualToString:imageUrlPath]) {
        _imageURLPath = imageUrlPath;
        if (self.isViewLoaded)
            [self fetchData];
    }
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.imageURLPath)
        [self fetchData];
}

#pragma mark - private

- (void) fetchData{
    if (self.imageURLPath == nil)
        return;
    
    __weak typeof(self) weakSelf = self;
    
    DEDImageProviderBlock block = ^(UIImage *image, NSError *error)
    {
        if (error == nil && image != nil)
            [weakSelf showImage:image];
        else
            [weakSelf showAlertWithError:error];
    };
    
    [[ImageProvider sharedInstance] provideImageForUrlPath:self.imageURLPath
                                           completionBlock:block];
}

- (void)showImage:(UIImage*)image{
    self.imageView.image = image;
    [self animateImageAppearance];
}


- (void)showAlertWithError:(NSError *)error{
    [[[UIAlertView alloc] initWithTitle:@"Download failed"
                                message:error.localizedDescription
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

- (void)animateImageAppearance{
    CATransition *transition = [CATransition animation];
    transition.duration = kImageFadeInAnimationTime;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [self.imageView.layer addAnimation:transition forKey:nil];
}

@end
