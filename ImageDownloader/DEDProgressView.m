//
//  DEDProgressView.m
//  ImageDownloader
//
//  Created by Dmitriy Kazhura on 20/07/15.
//  Copyright (c) 2015 SoundCuddy. All rights reserved.
//

#import "DEDProgressView.h"

@interface DEDProgressView (){
    CGFloat _progress;
}

@property (nonatomic, strong) UIView *fillView;

@end

@implementation DEDProgressView

#pragma mark - public

- (void)setProgress:(CGFloat)progress{
    _progress = progress;
    CGRect fillFrame = self.fillView.frame;
    fillFrame.size.width = self.bounds.size.width * _progress;
    self.fillView.frame = fillFrame;
}

#pragma mark - private

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.fillView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, self.bounds.size.height)];
        self.fillView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor grayColor];
        self.fillView.backgroundColor = [UIColor blueColor];
        [self addSubview:self.fillView];
    }
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self setProgress:_progress];
}

@end
