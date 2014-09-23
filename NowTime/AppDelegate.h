//
//  AppDelegate.h
//  NowTime
//
//  Created by Paul Rolfe on 8/24/14.
//  Copyright (c) 2014 Paul Rolfe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ParseKeys.h" //You need to add this file for your own parse app

/*
 ParseKeys.h will say something like this:
 
 #define APPLICATION_ID @"your info here"
 #define CLIENT_KEY @"your info here"
 
 */

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
