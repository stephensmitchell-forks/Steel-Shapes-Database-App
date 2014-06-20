//
//  AW_AppDelegate.m
//  Steel Shapes Database
//
//  Created by Alan Wang on 5/15/14.
//  Copyright (c) 2014 Alan Wang. All rights reserved.
//

#import "AW_AppDelegate.h"
#import "AW_CoreDataStore.h"
#import "AW_NavigationController.h"
#import "AW_DatabaseTableViewController.h"
#import "AW_FavoritesTableViewController.h"
#import "AW_AboutViewController.h"
#import "AW_Database.h"

//// test
//#import "AW_Database.h"
//#import "AW_ShapeFamily.h"
//#import "AW_Shape.h"
//#import "AW_PropertyViewController.h"

@implementation AW_AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    
    // For "Browse" tab
    AW_DatabaseTableViewController *databaseVC = [[AW_DatabaseTableViewController alloc] init];
    AW_NavigationController *browseNavController = [[AW_NavigationController alloc] initWithRootViewController:databaseVC];
    
    // For "Favorites" tab
    AW_FavoritesTableViewController *favController = [[AW_FavoritesTableViewController alloc]initWithStyle:UITableViewStylePlain];
    AW_NavigationController *favNavController = [[AW_NavigationController alloc] initWithRootViewController:favController];
    
//    // TEST..........
//    NSArray *databases = [[AW_CoreDataStore sharedStore]fetchAW_DatabaseObjects];
//    AW_Database *database = databases[0];
//    AW_ShapeFamily *randomFamily = database.shapeFamilies.allObjects[0];
//    AW_Shape *randomShape = randomFamily.shapes.allObjects[0];
//    
//    [[AW_CoreDataStore sharedStore]returnObjectToFault:randomFamily];
//    [[AW_CoreDataStore sharedStore]returnObjectToFault:database];
//    
//    AW_PropertyViewController *vc = [[AW_PropertyViewController alloc]initWithShape:randomShape];
//    favController = vc;
//    //.................
    
    // For "About" tab
    AW_AboutViewController *aboutVC = [[AW_AboutViewController alloc]initWithNibName:@"AW_AboutViewController" bundle:[NSBundle mainBundle]];
    
    // Set icons and titles for tabs
    // It would be nice to do this in the designated initializers of the VC's, but I don't know which ones they are
    favNavController.tabBarItem.title = @"Favorites";
    browseNavController.tabBarItem.title = @"Browse";
    aboutVC.tabBarItem.title = @"About";
    
    
    // Root view controller
    UITabBarController *tabBarController = [[UITabBarController alloc]init];
    tabBarController.viewControllers = @[browseNavController, favNavController, aboutVC];
    //tabBarController.tabBar.translucent = NO;
    
    self.window.rootViewController = tabBarController;
    
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
