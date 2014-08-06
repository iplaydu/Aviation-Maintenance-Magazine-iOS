//
//  LoginViewController.h
//  avm
//
//  Created by Gregory Lampa on 19/12/2013.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController<NSXMLParserDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *username;
@property (strong, nonatomic) IBOutlet UITextField *password;


- (NSString *) md5:(NSString *) input;

- (IBAction)loginMethod:(id)sender;
- (IBAction)registerMethod:(id)sender;
- (IBAction)cancelMethod:(id)sender;


@end

