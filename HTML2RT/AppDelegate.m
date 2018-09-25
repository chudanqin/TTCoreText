//
//  AppDelegate.m
//  HTML2RT
//
//  Created by chudanqin on 2018/8/27.
//  Copyright © 2018 chudanqin. All rights reserved.
//

#import "TTBookViewController.h"
#import "TTXMLParser.h"
#import "AppDelegate.h"

@interface TTObject : NSObject
@property (nonatomic, copy) dispatch_block_t block;
@end

@implementation TTObject

- (void)dealloc
{
    NSLog(@"TTObject dealloc");
}
@end

@interface AppDelegate () <TTHTMLParserDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    NSURL *URL = [[NSBundle mainBundle] URLForResource:@"tt" withExtension:@"html"];
//    NSData *data = [NSData dataWithContentsOfURL:URL];
//    NSError *error;
//    TTHTMLParser *parser = [TTHTMLParser instanceWithData:data delegate:self error:&error];
//    [parser start];
//    // Override point for customization after application launch.
//    
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
//    button.backgroundColor = [UIColor redColor];
//    button.frame = CGRectMake(0.0, 100.0, 50.0, 50.0);
//    [[(UINavigationController *)self.window.rootViewController viewControllers].firstObject.view addSubview:button];
    return YES;
}

- (void)clickButton:(id)sender {
    TTBookViewController *bvc = [[TTBookViewController alloc] initWithNibName:nil bundle:nil];
    [(UINavigationController *)self.window.rootViewController pushViewController:bvc animated:YES];
}

- (void)parser:(TTHTMLParser *)parser needsCSSWithHyperRef:(NSString *)href completion:(void (^)(const char *, NSURL *))completion {
    NSURL *URL = [[NSBundle mainBundle] URLForResource:@"tt" withExtension:@"css"];
    completion(NULL, URL);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
