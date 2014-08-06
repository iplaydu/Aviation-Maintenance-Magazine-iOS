//
//  LoginViewController.m
//  avm
//
//  Created by Gregory Lampa on 19/12/2013.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import "LoginViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "Constants.h"


@interface LoginViewController () {
    BOOL authenticated;
    UIApplication * _registerationApplication;
    NSMutableString * currentValue;
    NSString * statusResponse;
    NSString * substatusResponse;
    NSUserDefaults *defaults;
}

@end

@implementation LoginViewController
@synthesize password, username;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    NSArray *nib =[[NSBundle mainBundle]loadNibNamed:@"LoginViewiPad" owner:self options:nil];
//    self.view = [nib objectAtIndex:0];
    
    self.password.delegate = self;
    self.username.delegate = self;
        
    
    if ( IDIOM == IPAD ) {
        NSArray *nib =[[NSBundle mainBundle]loadNibNamed:@"LoginViewiPad" owner:self options:nil];
        self.view = [nib objectAtIndex:0];
    } else {
        NSArray *nib =[[NSBundle mainBundle]loadNibNamed:@"LoginViewiPhone" owner:self options:nil];
        self.view = [nib objectAtIndex:0];
    }

    
}

-(void)viewDidAppear:(BOOL)animated
{
    defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *passwordTemp = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
    NSString *usernameTemp = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    
    
    NSLog(@"The user defaults are, Username: %@ | and Password: %@",usernameTemp, passwordTemp);

    if(passwordTemp != nil && usernameTemp != nil) {
        
        UIActivityIndicatorView * activityIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(150, 200, 30, 30)];
        [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityIndicator setColor:[UIColor redColor]];
        [self.view addSubview:activityIndicator];
        [activityIndicator startAnimating];
        

        NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"http://beelinedb.whiteroomsolutions.com/public/check-sub-status.php?db=aerospace&prod=AVM&username=%@&password=%@", [defaults stringForKey:@"username"], [self md5:[defaults stringForKey:@"password"]]]];
        
        NSMutableURLRequest  *request = [NSMutableURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
            
            
            NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:data];
            [xmlParser setDelegate:self];
            [xmlParser parse];
            
            //Username - malcolm.coleman@live.co.uk
            //Password - test123 (md5 hash)
            
            if ([statusResponse isEqualToString:@"OK"] && [substatusResponse isEqualToString:@"True"]) {
                
                [activityIndicator stopAnimating];
                                
                [self dismissViewControllerAnimated:YES completion:nil];

            } else {
                
                [activityIndicator stopAnimating];

                //Reset the User defaults
                self.username.text = @"";
                self.password.text = @"";
                authenticated = NO;
                
                [defaults setObject:self.username.text forKey:@"username"];
                [defaults setObject:self.password.text forKey:@"password"];
                [defaults setInteger:authenticated forKey:@"authenticated"];
                
            }
            
        }];
    } else {
        
    }
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

// It is important for you to hide kwyboard

- (BOOL)textFieldShouldReturn:(UITextField *)textField{

    if (textField.tag == 1) {
        UITextField *password = (UITextField *)[self.view viewWithTag:2];
        [self.password becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    return YES;
}

- (IBAction)cancelMethod:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)registerMethod:(id)sender {
    if(!_registerationApplication){
        _registerationApplication = [UIApplication sharedApplication];
        [_registerationApplication openURL:[NSURL URLWithString:@"http://beelinedb.whiteroomsolutions.com/public/do-reg-form.php?productId=1&database=aerospace"]];
    }
}

- (IBAction)loginMethod:(id)sender {
    
    if ([self.username.text length] != 0 && [self.password.text length] != 0) {
        
        
        UIActivityIndicatorView * activityIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(150, 200, 30, 30)];
        [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityIndicator setColor:[UIColor grayColor]];
        //[activityIndicator setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
        [self.view addSubview:activityIndicator];
        [activityIndicator startAnimating];
        
        
        NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"http://beelinedb.whiteroomsolutions.com/public/check-sub-status.php?db=aerospace&prod=AVM&username=%@&password=%@", self.username.text, [self md5:self.password.text]]];
        
        NSMutableURLRequest  *request = [NSMutableURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
            
            NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:data];
            [xmlParser setDelegate:self];
            [xmlParser parse];
            
            if ([statusResponse isEqualToString:@"OK"] && [substatusResponse isEqualToString:@"True"]) {
                
                [activityIndicator stopAnimating];
                
                authenticated = YES;
                
                [defaults setObject:self.username.text forKey:@"username"];
                [defaults setObject:self.password.text forKey:@"password"];
                [defaults setInteger:authenticated forKey:@"authenticated"];
   
                NSLog(@"The user authenticated and the new set defaults are, Username: %@ | and Password: %@",self.username.text, self.password.text);

                NSString *passwordTemp = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
                NSString *usernameTemp = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
                
                
                NSLog(@"The user saved defaults are, Username: %@ | and Password: %@",usernameTemp, passwordTemp);

                [self dismissViewControllerAnimated:YES completion:nil];
                
            } else {
                
                //Reset the User defaults
                self.username.text = @"";
                self.password.text = @"";
                
                [activityIndicator stopAnimating];
            }
            
        }];
    } else {
        self.username.text = @"";
        self.password.text = @"";
    }
 }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma NSXMLParserDelegate Methods

-(void)parserDidStartDocument:(NSXMLParser *)parser
{
    currentValue = [[NSMutableString alloc] init];
}

-(void)parser:(NSXMLParser *) parser
didStartElement:(NSString *)elementName
 namespaceURI:(NSString *)namespaceURI
qualifiedName:(NSString *)qName
   attributes:(NSDictionary *)attributeDict
{
    [currentValue setString:@""];
}

-(void)parser:(NSXMLParser *) parser
foundCharacters:(NSString *)string
{
    [currentValue appendString:string];
}

-(void)parser:(NSXMLParser *)parser
didEndElement:(NSString *)elementName
 namespaceURI:(NSString *)namespaceURI
qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"status"]) {
        statusResponse = [currentValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    if ([elementName isEqualToString:@"substatus"]) {
        substatusResponse = [currentValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
}

-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    dispatch_async(dispatch_get_main_queue(), ^{});
}

-(void)parser:(NSXMLParser *)parser
parseErrorOccurred:(NSError *)parseError
{
    
}

#pragma MD5 String Conversion

- (NSString *) md5:(NSString *) input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
    
}

@end
