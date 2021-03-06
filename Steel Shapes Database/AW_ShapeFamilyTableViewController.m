//
//  AW_ShapeFamilyTableViewController.m
//  Steel Shapes Database
//
//  Created by Alan Wang on 5/21/14.
//  Copyright (c) 2014 Alan Wang. All rights reserved.
//

#import "AW_CoreDataStore.h"
#import "AW_Database.h"
#import "AW_ShapeFamily.h"
#import "AW_ShapeFamilyTableViewController.h"
#import "AW_ShapeViewController.h"

@interface AW_ShapeFamilyTableViewController ()

@property (nonatomic, strong) NSArray *tableData; // Two-Dimensional array storing shape families by section


@end

@implementation AW_ShapeFamilyTableViewController

#pragma mark - Custom Accessors
-(NSArray *)tableData
{
    if (!_tableData) {
        // Get list of shape families from database
        NSArray *shapeFamilyList = [self.database.shapeFamilies allObjects];
        NSSortDescriptor *sortByOrder = [NSSortDescriptor sortDescriptorWithKey:@"defaultOrder" ascending:YES];
        shapeFamilyList = [shapeFamilyList sortedArrayUsingDescriptors:@[sortByOrder]];
        
        // Organize shape families into groups
        NSMutableArray *tableDataTemp = [[NSMutableArray alloc]init];
        
        NSMutableDictionary *groupIndex = [[NSMutableDictionary alloc]init];
        
        for (AW_ShapeFamily *family in shapeFamilyList) {
            
            NSString *groupName = family.group;
            NSMutableArray *groupStore;
            
            if (!groupIndex[groupName]) {
                // This is a new group. Create an NSMutableArray for it and add it to the dictionary and tableData array
                groupStore = [[NSMutableArray alloc]init];
                [groupIndex setObject:groupStore forKey:groupName];
                [tableDataTemp addObject:groupStore];
            }
            else {
                groupStore = groupIndex[groupName];
            }
            
            [groupStore addObject:family];
        }
        
        
        _tableData = [tableDataTemp copy];
    }
    
    return _tableData;
}

#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"AW_ShapeFamilyViewController did load");
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Set table view stuff
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    
    // Set database title for navigation bar
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:17.0];   //Matches Apple's default nav bar title font
    titleLabel.textColor = self.database.textColor;
    titleLabel.text = self.database.shortName;
    [titleLabel sizeToFit];
    
    self.navigationItem.titleView = titleLabel;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"AW_ShapeFamilyViewController will appear");
    
    // Set colors for navigation bar and tab bar
    // This is necessary in viewWillAppear to have a better transition between view controllers
    self.navigationController.navigationBar.barTintColor = self.database.backgroundColor;
    self.navigationController.navigationBar.tintColor = self.database.textColor;
    ((UILabel *)self.navigationItem.titleView).textColor = self.database.textColor;
    self.tabBarController.tabBar.barTintColor = self.database.backgroundColor;
    self.tabBarController.tabBar.tintColor = self.database.textColor;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"AW_ShapeFamilyViewController did appear");
    
    // This is for the special case where you switch tabs while on this view controller
    // For some reason, viewWillDisappear is fired when switching tabs, causing the title to lose its color,
    // but viewWillAppear does not fire when switching back to the tab with this VC. viewDidAppear is fired,
    // so the code to change the color back is included here.
    self.navigationController.navigationBar.barTintColor = self.database.backgroundColor;
    self.navigationController.navigationBar.tintColor = self.database.textColor;
    ((UILabel *)self.navigationItem.titleView).textColor = self.database.textColor;
    self.tabBarController.tabBar.barTintColor = self.database.backgroundColor;
    self.tabBarController.tabBar.tintColor = self.database.textColor;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"AW_ShapeFamilyViewController will disappear");
    // Return title view's color to default. This is necessary for consistency in colors when transitioning between views
    ((UILabel *)self.navigationItem.titleView).textColor = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // Return all managed objects to faults
    for (AW_ShapeFamily *family in self.database.shapeFamilies)
    {
        [[AW_CoreDataStore sharedStore]returnObjectToFault:family];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.tableData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.tableData[section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    AW_ShapeFamily *family = self.tableData[indexPath.section][indexPath.row];
    cell.textLabel.text = family.displayName;
    
    cell.imageView.image = family.image;
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AW_ShapeFamily *family = self.tableData[indexPath.section][indexPath.row];
    
    // Create next view controller
    AW_ShapeViewController *shapeVC = [[AW_ShapeViewController alloc]initWithNibName:@"AW_ShapeViewController" bundle:[NSBundle mainBundle]];
    shapeVC.shapeFamily = family;
    
    // Display next view controller
    [self.navigationController pushViewController:shapeVC animated:YES];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
