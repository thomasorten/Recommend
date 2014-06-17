//
//  AddRecommendationViewController.m
//  Recommend
//
//  Created by Thomas Orten on 6/16/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "AddRecommendationViewController.h"

@interface AddRecommendationViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *cameraScrollView;
@property UITextField *activeTextField;
@property UITextView *activeTextView;
@end

@implementation AddRecommendationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self registerForKeyboardNotifications];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];

    [self.view addGestureRecognizer:tap];

    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {

        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.showsCameraControls = NO;
        CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 27.0);
        CGAffineTransform scale = CGAffineTransformScale(translate, 1.6, 1.6);
        picker.cameraViewTransform = scale;
        picker.cameraOverlayView = self.view;

        if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            picker.cameraDevice =  UIImagePickerControllerCameraDeviceRear;
        } else {
            picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }

        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (IBAction)onAlbumPressed:(id)sender
{
    
}

- (IBAction)onTakePhotoPressed:(id)sender
{

}

- (IBAction)onFlashPressed:(id)sender
{

}

- (IBAction)onSetLocationPressed:(id)sender
{

}

- (BOOL) textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    static const NSUInteger MAX_NUMBER_OF_LINES_ALLOWED = 3;

    NSMutableString *t = [NSMutableString stringWithString:
                          self.descriptionTextView.text];
    [t replaceCharactersInRange: range withString: text];

    NSUInteger numberOfLines = 0;
    for (NSUInteger i = 0; i < t.length; i++) {
        if ([[NSCharacterSet newlineCharacterSet]
             characterIsMember: [t characterAtIndex: i]]) {
            numberOfLines++;
        }
    }

    return (numberOfLines < MAX_NUMBER_OF_LINES_ALLOWED);
}

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];

}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.cameraScrollView.contentInset = contentInsets;
    self.cameraScrollView.scrollIndicatorInsets = contentInsets;

    CGRect fieldFrame = self.activeTextField ? self.activeTextField.frame : self.activeTextView.frame;
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    CGPoint origin = fieldFrame.origin;
    origin.y -= (self.cameraScrollView.contentOffset.y-150);
    if (!CGRectContainsPoint(aRect, origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, (fieldFrame.origin.y+150)-(aRect.size.height));
        [self.cameraScrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.cameraScrollView.contentInset = contentInsets;
    self.cameraScrollView.scrollIndicatorInsets = contentInsets;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeTextField = nil;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqual:@"Write a short description here."]) {
        textView.text = @"";
    }
    self.activeTextView = textView;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqual:@""]) {
        textView.text = @"Write a short description here.";
    }
    self.activeTextView = nil;
}

@end
