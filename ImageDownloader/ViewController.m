//
//  ViewController.m
//  ImageDownloader
//
//  Created by Стребков Константин on 29.06.15.
//  Copyright (c) 2015 SoundCuddy. All rights reserved.
//

#import "ViewController.h"
#import "ImageProvider.h"

static const NSTimeInterval kImageFadeInAnimationTime = 0.3;

@interface ViewController () <ImageProviderDelegate>

@property (nonatomic, weak) IBOutlet UIImageView  *imageView;

@property (nonatomic, strong) ImageProvider *imageProvider;

@end

@implementation ViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageProvider = [[ImageProvider alloc] init];
    self.imageProvider.delegate = self;
}

#pragma mark - IBActions

- (IBAction)downloadImageButtonPressed:(id)sender {
    [self.imageProvider provideImageForUrlPath:@"http://instantsite.ru/gallery/image.php?album_id=12&image_id=19&view=no_count"];
}

#pragma mark - ImageProviderDelegate

- (void)imageProvider:(ImageProvider*)imageProvider
      didProvideImage:(UIImage*)image
           forURLPath:(NSString*)urlPath{
    
    self.imageView.image = image;
    [self animateImageAppearance];
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
