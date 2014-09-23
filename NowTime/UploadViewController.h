//
//  UploadViewController.h
//  NowTime
//
//  Created by Paul Rolfe on 9/1/14.
//  Copyright (c) 2014 Paul Rolfe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface UploadViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *headlineField;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
- (IBAction)uploadAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
- (IBAction)backAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *imageUploadButton;
- (IBAction)imageUploadAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *textView;
- (IBAction)dismissKeyboard:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *uploadedImage;


@end
