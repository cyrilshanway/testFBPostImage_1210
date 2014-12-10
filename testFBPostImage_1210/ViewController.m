//
//  ViewController.m
//  testFBPostImage_1210
//
//  Created by Cyrilshanway on 2014/12/10.
//  Copyright (c) 2014年 Cyrilshanway. All rights reserved.
//

#import "ViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AFNetworking.h"

@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;
@property (nonatomic,strong)UIImage *profileImage;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIImageView *imageByn;

@property (weak, nonatomic) IBOutlet UIButton *photoBtn;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)logoutBtnPressed:(id)sender {
   
    [FBSession.activeSession closeAndClearTokenInformation];
}



- (IBAction)loginButtonClicked:(id)sender
{
    if (FBSession.activeSession.state == FBSessionStateOpen || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        [FBSession.activeSession closeAndClearTokenInformation];
    } else {
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email", @"publish_actions", @"read_stream"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *FBuser, NSError *error) {
                 if (error) {
                     // Handle error
                     NSLog(@"[fb login] an error occurs");
                 }
                 else {
                     NSMutableDictionary *userData = [[NSMutableDictionary alloc] init];
                     
                     [userData setObject:[FBuser objectForKey:@"id"] forKey:@"id"];
                     
                     if ([[FBuser allKeys] containsObject:@"email"])
                         [userData setObject:[FBuser objectForKey:@"email"]  forKey:@"UserName"];
                     else
                         [userData setObject:@""  forKey:@"UserName"];
                     
                     if ([[FBuser allKeys] containsObject:@"name"])
                         [userData setObject:[FBuser objectForKey:@"name"]   forKey:@"NickName"];
                     else
                         [userData setObject:@""  forKey:@"NickName"];
                     
                     self.loginBtn.hidden = YES;
                     self.logoutBtn.hidden = NO;
                     self.photoBtn.hidden = NO;
                     
                     NSString *fbAccessToken = [[[FBSession activeSession] accessTokenData] accessToken];
                     NSDate *expireationdate = [[[FBSession activeSession] accessTokenData] expirationDate];
                     
                     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                     
                     [defaults setObject:fbAccessToken forKey:@"FBAccessTokenKey"];
                     [defaults setObject:expireationdate forKey:@"FBExpirationDateKey"];
                     
                     [defaults synchronize];
                     
                     NSString *profileImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=240&height=240", [FBuser objectForKey:@"id"]];
                     
                     [defaults setObject:profileImageURL forKey:@"Photo"];
                     
                     NSURL *imageURL = [NSURL URLWithString:profileImageURL];
                     AFImageRequestOperation* imageOperation = [AFImageRequestOperation imageRequestOperationWithRequest: [NSURLRequest requestWithURL:imageURL] success:^(UIImage *image) {
                         NSLog(@"Get Image from facebook");
                         self.profileImage = image;
                         self.imageByn.image = image;
                         [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshTable" object:nil];
                     }];
                     
                     NSOperationQueue* queue = [[NSOperationQueue alloc] init];
                     [queue addOperation:imageOperation];
                     
                     //[self.delegate loginReturn:YES userInfo:userData FailWithError:nil];
                 }
             }];
         }];
    }
}

- (BOOL)isFBsessionValid
{
    NSUserDefaults *defaults =  [NSUserDefaults standardUserDefaults];
    NSString *accessToken = [defaults objectForKey:@"GeneralAccessTokenKey"];
    if (accessToken == nil)
        return NO;
    
    if (FBSession.activeSession.state == FBSessionStateOpen || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        return YES;
    }
    else {
        return NO;
    }
}


- (IBAction)takePhotoBtnPressed:(id)sender {
    //[self FBPost];
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        [self presentViewController:imagePicker animated:YES completion:NULL];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
    NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/profile.jpg"];
    UIImage *currentImg = image;
    [UIImageJPEGRepresentation(currentImg, 1.0) writeToFile:savePath atomically:YES];
    
    UIImage *profileImage = [UIImage imageWithContentsOfFile:savePath];
    //[pictureButton setBackgroundImage:profileImage forState:UIControlStateNormal];
    self.imageByn.image = [UIImage imageWithContentsOfFile:savePath];
    
    [picker dismissModalViewControllerAnimated:YES];
}



- (void)FBPost{
    //    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
    //                                   kAppId, @"app_id",
    //                                   @"http://chings228.wordpress.com/2012/04/05/facebook-login-for-ios-part-1-singleton/", @"link",
    //                                   @"http://www.shopandpark.com/images/sp_fb.gif", @"picture",
    //                                   @"Wordpress", @"name",
    //                                   @"facebook ios demo", @"caption",
    //                                   @"singleton ", @"description",
    //                                   nil];
    //
    //    postRequest = [facebook requestWithGraphPath:@"me/feed" andParams:params andHttpMethod:@"POST" andDelegate:self];
    // UIImage *image = [UIImage imageNamed:@"test.png"];
    
//    NSLog(@"[MESSAGE] fb message: %@", message);
//    NSLog(@"[MESSAGE] song url: %@", url);
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@"測試圖片" forKey:@"message"];
    [params setObject:UIImagePNGRepresentation(self.imageByn.image ) forKey:@"picture"];
    
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                   img, @"picture",
//                                   message, @"message",
//                                   url, @"link",
//                                   nil];
    
    // Make the request
    [FBRequestConnection startWithGraphPath:@"/me/photos"
                                 parameters:params
                                 HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error) {
                                  // Link posted successfully to Facebook
                                  NSLog([NSString stringWithFormat:@"Post to wall done: %@", result]);
                                  [[NSNotificationCenter defaultCenter] postNotificationName:@"postReturn" object:nil];
                              } else {
                                  // An error occurred, we need to handle the error
                                  // See: https://developers.facebook.com/docs/ios/errors
                                  NSLog([NSString stringWithFormat:@"%@", error.description]);
                              }
                          }];

    
}
@end
