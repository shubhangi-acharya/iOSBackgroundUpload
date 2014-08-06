//
//  AppDelegate.h
//  iOSBackgroundUpload
//
//  Created by MEGANEXUS on 06/08/14.
//  Copyright (c) 2014 sample. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

// Background task completion handler
@property (copy) void (^backgroundSessionCompletionHandler)();
@property (strong, nonatomic) UIWindow *window;

@end
