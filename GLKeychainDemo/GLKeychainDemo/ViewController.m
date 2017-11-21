//
//  ViewController.m
//  GLKeychainDemo
//
//  Created by GrayLand on 2017/11/21.
//  Copyright © 2017年 BodyPlus. All rights reserved.
//

#import "ViewController.h"
#import "GLKeychain.h"

static NSString * const kPasswordKey = @"kPasswordKey";

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[GLKeychain defaultManager] setupKeyChain];
    [[GLKeychain defaultManager] changeToAccount:@"FakerUser10001"];
    [[GLKeychain defaultManager] changeToService:@"MyLoginService"];
}

- (IBAction)onSaveBtn:(id)sender {
    [[GLKeychain defaultManager] savePassword:_pwdTextField.text];
}

- (IBAction)onReadBtn:(id)sender {
    _pwdTextField.text = [[GLKeychain defaultManager] readPassword];
}

- (IBAction)onClearTextBtn:(id)sender {
    _pwdTextField.text = @"";
}
@end
