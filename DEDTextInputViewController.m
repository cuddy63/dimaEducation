//
//  DEDTextInputViewController.m
//  
//
//  Created by Dmitriy Kazhura on 02/07/15.
//
//

#import "DEDTextInputViewController.h"
#import "DEDImageDisplayViewController.h"
#import "ImageProvider.h"

@interface DEDTextInputViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation DEDTextInputViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.textField becomeFirstResponder];

}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DEDImageDisplayViewController *vc = [segue destinationViewController];
    [vc setImageURLPath:self.textField.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


@end
