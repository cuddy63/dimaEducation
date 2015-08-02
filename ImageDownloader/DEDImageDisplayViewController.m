//
//  ViewController.m
//  ImageDownloader
//
//  Created by Стребков Константин on 29.06.15.
//  Copyright (c) 2015 SoundCuddy. All rights reserved.
//

#import "DEDImageDisplayViewController.h"
#import "DEDImageProvider.h"
#import "DEDProgressView.h"

@class DEDTextInputViewController;
static const NSTimeInterval kImageFadeInAnimationTime = 0.3;

@interface DEDImageDisplayViewController ()

@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak,   nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) DEDProgressView *myProgressView;

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
    self.progressView.hidden = YES;
    self.myProgressView = [[DEDProgressView alloc] initWithFrame:self.progressView.frame];
    [self.view addSubview:self.myProgressView];
}


- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.myProgressView.frame = self.progressView.frame;
}

#pragma mark - private

- (void)fetchData {
    if (self.imageURLPath == nil)
        return;
    
    __block BOOL performedSync = YES;
    __weak typeof(self) weakSelf = self;
    
    self.myProgressView.hidden = NO;
    self.myProgressView.progress = 0.0;
    
    DEDImageProviderDownloadBlock completion = ^(UIImage *image, NSError *error)
    {
        if (error == nil && image != nil)
            [weakSelf showImage:image animated:!performedSync];
        else
            [weakSelf showAlertWithError:error];
        
        weakSelf.myProgressView.hidden = YES;
    };
    [[DEDImageProvider sharedInstance] downloadImageWithAFNFromURL:self.imageURLPath
                                                     progressBlock:^(CGFloat progress) {
                                                         weakSelf.myProgressView.progress = progress;
                                                     } withCompletion:completion];
    performedSync = NO;
    
}

- (void)showImage:(UIImage*)image animated:(BOOL)animated {
    self.imageView.image = image;
    if (animated)
        [self animateImageAppearance];
}


- (void)showAlertWithError:(NSError *)error {
    [[[UIAlertView alloc] initWithTitle:@"Download failed"
                                message:error.localizedDescription
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

- (void)animateImageAppearance {
    CATransition *transition = [CATransition animation];
    transition.duration = kImageFadeInAnimationTime;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [self.imageView.layer addAnimation:transition forKey:nil];
}

@end
