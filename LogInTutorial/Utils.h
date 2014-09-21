//
//  Utils.h
//  YouTube Direct Lite for iOS
//
//  Created by Ibrahim Ulukaya on 11/6/13.
//  Copyright (c) 2013 Google. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const DEFAULT_KEYWORD = @"ytdl";
static NSString *const UPLOAD_PLAYLIST = @"PLZX5tIvSu3S_7_eEGBMlkcM1kejzPIyQU";//@"PLDbx88rxRWgb8k2FI5SS82pjKZPX45k3j";//@"Replace me with the playlist ID you want to upload into";
static NSString *const kClientID = @"304098664997-3981ie2basjdugc6b7sk817dn5qhmc0m.apps.googleusercontent.com";//@"Replace me with your project's Client ID";
static NSString *const kClientSecret = @"LwUtLWCxzOpVSwujhXbm3ME1";//@"Replace me with your project's Client Secret";

static NSString *const kKeychainItemName = @"YouTube Direct Lite";

@interface Utils : NSObject

+ (UIAlertView*)showWaitIndicator:(NSString *)title;
+ (void)showAlert:(NSString *)title message:(NSString *)message;
+ (NSString *)humanReadableFromYouTubeTime:(NSString *)youTubeTimeFormat;

@end
