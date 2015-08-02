//
//  DEDTextInputViewController.m
//  
//
//  Created by Dmitriy Kazhura on 02/07/15.
//
//

#import "DEDTextInputViewController.h"
#import "DEDImageDisplayViewController.h"
#import "DEDImageProvider.h"

@interface DEDTextInputViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DEDTextInputViewController {
    NSMutableArray *urlArray;
    NSInteger rowIndex;
    NSInteger rowCount;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.textField becomeFirstResponder];
    self.tableView.dataSource = self;
    rowCount = 1;
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return rowCount;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* reusableCellIdentifier = @"URL Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableCellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusableCellIdentifier];
    cell.backgroundColor = tableView.backgroundColor;
    cell.textLabel.text = [urlArray objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:12.0f];
//    cell.textLabel.textAlignment = UITextAlignmentCenter;
//    UIButton *showImageButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    showImageButton.frame = CGRectMake(0.0f, 5.0f, 320.0f, 44.0f);
//    showImageButton.backgroundColor = [UIColor blueColor];
//    [showImageButton setTitle:@"Show image" forState:UIControlStateNormal];
//    [cell addSubview:showImageButton];
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"pushFromCellSegue" sender:self];
    rowIndex = indexPath.row;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DEDImageDisplayViewController *vc = [segue destinationViewController];
    if ([[segue identifier] isEqualToString:@"pushFromCellSegue"]) {
        [vc setImageURLPath:[urlArray objectAtIndex:rowIndex]];
        return;
    }
    [vc setImageURLPath:self.textField.text];
    if (urlArray.count == 0) {
        urlArray = [NSMutableArray arrayWithObject:self.textField.text];
    } else {
        for (NSString *string in urlArray) {
            if (![self.textField.text isEqual:string])
                [urlArray addObject:self.textField.text];
            
        }
    }
    rowCount = rowCount + 1;
    [self.tableView reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


@end
