//
//  BRCEmbargoPasscodeViewController.m
//  iBurn
//
//  Created by David Chiles on 8/7/14.
//  Copyright (c) 2014 Burning Man Earth. All rights reserved.
//

#import "BRCEmbargoPasscodeViewController.h"
#import "PureLayout.h"
#import "DAKeyboardControl.h"
#import "BRCEmbargo.h"
#import "NSUserDefaults+iBurn.h"
#import "BRCAppDelegate.h"
#import "TTTTimeIntervalFormatter+iBurn.h"
#import "BRCEventObject.h"

@interface BRCEmbargoPasscodeViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UIButton *unlockBotton;
@property (nonatomic, strong) UIButton *noPasscodeButton;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UITextField *passcodeTextField;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UILabel *countdownLabel;
@property (nonatomic) BOOL didAddConstraints;
@property (nonatomic, strong) NSTimer *countdownTimer;
@property (nonatomic, strong) NSLayoutConstraint *bottomCostraint;
@property (nonatomic, strong) NSLayoutConstraint *textFieldAxisConstraint;
@property (nonatomic, strong) TTTTimeIntervalFormatter *timerFormatter;

@end

@implementation BRCEmbargoPasscodeViewController

- (void) dealloc {
    [self.countdownTimer invalidate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.didAddConstraints = NO;
    
    self.containerView = [[UIView alloc] initForAutoLayout];
    
    self.noPasscodeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.noPasscodeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.noPasscodeButton addTarget:self action:@selector(nopasscodeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.noPasscodeButton setTitle:@"Skip" forState:UIControlStateNormal];
    self.noPasscodeButton.titleLabel.font = [UIFont systemFontOfSize:18];
    self.noPasscodeButton.tintColor = [UIColor grayColor];

    self.unlockBotton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.unlockBotton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.unlockBotton addTarget:self action:@selector(unlockButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.unlockBotton setTitle:@"Unlock" forState:UIControlStateNormal];
    self.unlockBotton.titleLabel.font = [UIFont boldSystemFontOfSize:18];

    
    self.descriptionLabel = [[UILabel alloc] initForAutoLayout];
    self.descriptionLabel.text = @"Camp location data is embargoed until the gates officially open due to BMorg's restrictions. The passcode will be released to the public at 10am on Sunday 8/24.\n\nFollow @iBurnApp on Twitter or Facebook for updates ahead of the event, or ask a Black Rock Ranger or Burning Man Staffer.";
    self.descriptionLabel.font = [UIFont systemFontOfSize:15];
    self.descriptionLabel.numberOfLines = 0;
    
    self.passcodeTextField = [[UITextField alloc] initForAutoLayout];
    self.passcodeTextField.secureTextEntry = YES;
    self.passcodeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.passcodeTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.passcodeTextField.returnKeyType = UIReturnKeyDone;
    self.passcodeTextField.delegate = self;
    self.passcodeTextField.placeholder = @"Passcode";
    
    self.countdownLabel = [[UILabel alloc] initForAutoLayout];
    self.countdownLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.countdownLabel.textAlignment = NSTextAlignmentCenter;
    self.countdownLabel.numberOfLines = 0;
    self.timerFormatter = [[TTTTimeIntervalFormatter alloc] init];
    
    self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(refreshCountdownLabel:) userInfo:nil repeats:YES];
    [self.countdownTimer fire];
    
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.descriptionLabel];
    [self.containerView addSubview:self.noPasscodeButton];
    [self.containerView addSubview:self.unlockBotton];
    [self.containerView addSubview:self.passcodeTextField];
    [self.containerView addSubview:self.countdownLabel];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(singleTapPressed:)];
    [self.view addGestureRecognizer:tapRecognizer];
    
    [self.view updateConstraintsIfNeeded];
    
    __weak BRCEmbargoPasscodeViewController *welf = self;
    [self.view addKeyboardNonpanningWithFrameBasedActionHandler:nil constraintBasedActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {
        if (opening)
        {
            welf.bottomCostraint.constant = -keyboardFrameInView.size.height;
            [UIView animateWithDuration:0.2 animations:^{
                welf.descriptionLabel.alpha = 0.0f;
            }];
        }
        else if (closing)
        {
            welf.bottomCostraint.constant = 0.0;
            [UIView animateWithDuration:0.5 animations:^{
                welf.descriptionLabel.alpha = 1.0f;
            }];
        }
    }];
}

- (void) refreshCountdownLabel:(id)sender {
    NSMutableAttributedString *fullLabelString = nil;
    NSDate *now = [NSDate date];
    NSDate *festivalStartDate = [BRCEventObject festivalStartDate];
    NSTimeInterval timeLeftInterval = [now timeIntervalSinceDate:festivalStartDate];
    if (timeLeftInterval >= 0) {
        fullLabelString = [[NSMutableAttributedString alloc] initWithString:@"Gates Are Open"];
    } else {
        // Get conversion to months, days, hours, minutes
        unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSSecondCalendarUnit;
        
        NSDateComponents *breakdownInfo = [[NSCalendar currentCalendar] components:unitFlags fromDate:now  toDate:festivalStartDate options:0];
        
        NSMutableArray *fontSizingInfo = [NSMutableArray arrayWithCapacity:5];

        fullLabelString = [[NSMutableAttributedString alloc] initWithString:@""];
        
        if ([breakdownInfo day]) {
            NSString *daysString = [NSString stringWithFormat:@"%d days\n", (int)[breakdownInfo day]];
            [fontSizingInfo addObject:@[daysString, @(55)]];
        }
        if ([breakdownInfo hour]) {
            NSString *hoursString = [NSString stringWithFormat:@"%d hours\n", (int)[breakdownInfo hour]];
            [fontSizingInfo addObject:@[hoursString, @(35)]];
        }
        if ([breakdownInfo minute]) {
            NSString *minutesString = [NSString stringWithFormat:@"%d minutes\n", (int)[breakdownInfo minute]];
            [fontSizingInfo addObject:@[minutesString, @(20)]];
        }
        NSString *secondsString = [NSString stringWithFormat:@"%d seconds", (int)[breakdownInfo second]];
        [fontSizingInfo addObject:@[secondsString, @(15)]];
        
        __block NSUInteger startRange = 0;
        [fontSizingInfo enumerateObjectsUsingBlock:^(NSArray *fontSizingInfo, NSUInteger idx, BOOL *stop) {
            NSNumber *size = [fontSizingInfo lastObject];
            NSString *string = [fontSizingInfo firstObject];
            [fullLabelString appendAttributedString:[[NSAttributedString alloc] initWithString:string]];
            UIFont *font = [UIFont systemFontOfSize:[size floatValue]];
            [fullLabelString addAttribute:NSFontAttributeName
                                    value:font
                                    range:NSMakeRange(startRange, string.length)];
            startRange += string.length;
        }];
    }

    self.countdownLabel.attributedText = fullLabelString;
}

- (void) singleTapPressed:(id)sender {
    [self.passcodeTextField resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    
    if (self.didAddConstraints) {
        return;
    }
    [self.containerView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(30, 0, 0, 0) excludingEdge:ALEdgeBottom];
    self.bottomCostraint = [self.containerView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.view];
    
    [self.descriptionLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(10, 10, 10, 0) excludingEdge:ALEdgeBottom];
    
    self.textFieldAxisConstraint = [self.passcodeTextField autoAlignAxis:ALAxisVertical toSameAxisOfView:self.containerView];
    [self.passcodeTextField autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.descriptionLabel];
    [self.passcodeTextField autoSetDimension:ALDimensionHeight toSize:31.0];
    [self.passcodeTextField autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.noPasscodeButton withOffset:-10 relation:NSLayoutRelationGreaterThanOrEqual];
    
    [self.countdownLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.countdownLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
    [self.countdownLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    [self.countdownLabel autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.passcodeTextField withOffset:-10];
    [self.countdownLabel autoSetDimension:ALDimensionHeight toSize:150];
    
    [self.noPasscodeButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.containerView withOffset:10];
    [self.noPasscodeButton autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.containerView withOffset:-10];
    [self.noPasscodeButton autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.unlockBotton withOffset:10 relation:NSLayoutRelationGreaterThanOrEqual];
    [self.noPasscodeButton autoSetDimension:ALDimensionHeight toSize:44.0];
    
    
    [self.unlockBotton autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.containerView withOffset:-10];
    [self.unlockBotton autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.noPasscodeButton];
    [self.unlockBotton autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.noPasscodeButton];
    [self.unlockBotton autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.noPasscodeButton];
    
    
    self.didAddConstraints = YES;
}

- (void)nopasscodeButtonPressed:(id)sender
{
    [self showTabBarController];
}

- (void)unlockButtonPressed:(id)sender
{
    if ([BRCEmbargo isEmbargoPasscodeString:self.passcodeTextField.text]) {
        [[NSUserDefaults standardUserDefaults] setEnteredEmbargoPasscode:YES];
        [self showTabBarController];
    }
    else {
        [self shakeTextField:5];
    }
}

-(void)shakeTextField:(int)shakes {
    
    int direction = 1;
    if (shakes%2) {
        direction = -1;
    }
    
    if (shakes > 0) {
        self.textFieldAxisConstraint.constant = 5*direction;
    }
    else {
        self.textFieldAxisConstraint.constant = 0.0;
    }
    
    
    [UIView animateWithDuration:0.05 animations:^ {
        [self.view layoutIfNeeded];
    }
                     completion:^(BOOL finished)
     {
         if(shakes > 0)
         {
             [self shakeTextField:shakes-1];
         }
         
     }];
}

- (void)showTabBarController
{
    [self.view removeKeyboardControl];
    [((BRCAppDelegate *)[UIApplication sharedApplication].delegate) showTabBarAnimated:YES];
}

#pragma - mark UITextfieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self unlockButtonPressed:textField];
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


@end