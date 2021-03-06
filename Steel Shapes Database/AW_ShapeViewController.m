//
//  AW_ShapeTableViewController.m
//  Steel Shapes Database
//
//  Created by Alan Wang on 5/24/14.
//  Copyright (c) 2014 Alan Wang. All rights reserved.
//

#import "AW_CoreDataStore.h"
#import "AW_NavigationController.h"
#import "AW_ShapeViewController.h"
#import "AW_PropertyViewController.h"
#import "AW_Database.h"
#import "AW_ShapeFamily.h"
#import "AW_Shape.h"
#import "AW_InfoBar.h"

@interface AW_ShapeViewController ()

@property (nonatomic, strong) NSArray *tableData;
@property (nonatomic, strong) NSArray *imp_sectionIndex; // Stores section titles for use in index bar
@property (nonatomic, strong) NSArray *met_sectionIndex; // Stores ection titles for use in index bar
@property (nonatomic, strong) NSIndexPath *previousSelectionIndexPath; // Store the last selected shape


@end

@implementation AW_ShapeViewController

#pragma mark - Custom Accessors

// This also initializes and populates sectionIndex
-(NSArray *)tableData
{
    if (!_tableData) {
        // Get list of shapes from the shapeFamily
        NSArray *shapeList = [self.shapeFamily.shapes allObjects];
        NSSortDescriptor *sortByOrder = [NSSortDescriptor sortDescriptorWithKey:@"defaultOrder" ascending:NO];
        shapeList = [shapeList sortedArrayUsingDescriptors:@[sortByOrder]];
        
        // Organize shapes into groups
        NSMutableArray *tableDataTemp = [[NSMutableArray alloc]init];
        
        NSMutableDictionary *groupIndex = [[NSMutableDictionary alloc]init];
        
        for (AW_Shape *shape in shapeList) {
            
            NSString *groupName;
            if ([(AW_NavigationController *)self.navigationController isMetric]) {
                groupName = shape.met_group;
            }
            else {
                groupName = shape.imp_group;
            }
            
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
            
            [groupStore addObject:shape];
        }
        
        _tableData = [tableDataTemp copy];
    }
    
    return _tableData;
}

// Use lazy instantiation: imp_sectionIndex only needs to be built once, because the tableData will never change
- (NSArray *)imp_sectionIndex
{
    if (!_imp_sectionIndex) {
        NSMutableArray *output = [[NSMutableArray alloc]init];
        
        for (NSArray *section in self.tableData) {
            NSString *sectionName;
            AW_Shape *temp = section[0]; // Used to access the group name for this group
            
            sectionName = [temp formattedGroupNameForUnitSystem:0]; // 0 = Imperial
            [output addObject:sectionName];
        }
        
        _imp_sectionIndex = [output copy];
    }
    
    return _imp_sectionIndex;
}

// Use lazy instantiation: met_sectionIndex only needs to be built once, because the tableData will never change
- (NSArray *)met_sectionIndex
{
    if (!_met_sectionIndex) {
        NSMutableArray *output = [[NSMutableArray alloc]init];
        
        for (NSArray *section in self.tableData) {
            NSString *sectionName;
            AW_Shape *temp = section[0]; // Used to access the group name for this group
            
            sectionName = [temp formattedGroupNameForUnitSystem:1]; // 1 = Metric
            [output addObject:sectionName];
        }
        
        _met_sectionIndex = [output copy];
    }
    
    return _met_sectionIndex;
}

#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setup navigation bar
    if ([self.navigationController isKindOfClass:[AW_NavigationController class]]) {
        AW_NavigationController *navController = (AW_NavigationController *)self.navigationController;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:navController.unitSystem];

        
        // Set database title for navigation bar
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:17.0];   //Matches Apple's default nav bar title font
        titleLabel.textColor = self.navigationController.navigationBar.tintColor;
        titleLabel.text = self.shapeFamily.database.shortName;
        [titleLabel sizeToFit];
        
        self.navigationItem.titleView = titleLabel;
    }
    
    // Setup info bar
    self.infoBar.textLabel.text = self.shapeFamily.displayName;
    self.infoBar.imageView.image = self.shapeFamily.image;
    
    // Setup table view
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    self.tableView.sectionIndexColor = self.navigationController.navigationBar.barTintColor;
    self.tableView.sectionIndexTrackingBackgroundColor = [UIColor colorWithRed:(247/255.0) green:(247/255.0) blue:(247/255.0) alpha:1.0];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Reload tableView
    [self.tableView reloadData]; // This is okay to put in viewWillAppear because nothing you do in other tabs should affect the Shape VC
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Set target-action for unitSystem segmented control
    AW_NavigationController *navController = (AW_NavigationController *)self.navigationController;
    [navController.unitSystem addTarget:self
                                 action:@selector(switchImperialMetric)
                       forControlEvents:UIControlEventValueChanged];
    
    // Set colors
    self.navigationController.navigationBar.barTintColor = self.shapeFamily.database.backgroundColor;
    self.navigationController.navigationBar.tintColor = self.shapeFamily.database.textColor;
    ((UILabel *)self.navigationItem.titleView).textColor = self.shapeFamily.database.textColor;
    self.tabBarController.tabBar.barTintColor = self.shapeFamily.database.backgroundColor;
    self.tabBarController.tabBar.tintColor = self.shapeFamily.database.textColor;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Remove target-actions from the nav bar's unitSystem segmented control
    if ([self.navigationController isKindOfClass:[AW_NavigationController class]]) {
        AW_NavigationController *navController = (AW_NavigationController *)self.navigationController;

        [navController.unitSystem removeTarget:self
                                        action:@selector(switchImperialMetric)
                              forControlEvents:UIControlEventValueChanged];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    // Return all managed objects to faults
    for (AW_Shape *shape in self.shapeFamily.shapes)
    {
        [[AW_CoreDataStore sharedStore]returnObjectToFault:shape];
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
    
    // Configure the cell...
    AW_Shape *shape = self.tableData[indexPath.section][indexPath.row];
    
    cell.textLabel.text = [shape formattedDisplayNameForUnitSystem:[(AW_NavigationController *)self.navigationController isMetric]];
    
    if ([self.previousSelectionIndexPath isEqual:indexPath]) {
        [self.tableView selectRowAtIndexPath:self.previousSelectionIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    BOOL isMetric = [(AW_NavigationController *)self.navigationController isMetric];
    
    if (isMetric) {
        sectionName = self.met_sectionIndex[section];
    }
    else {
        sectionName = self.imp_sectionIndex[section];
    }
    
    return sectionName;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
//    NSArray *output;
//    BOOL isMetric = [(AW_NavigationController *)self.navigationController isMetric];
//    
//    if (isMetric) {
//        output = self.met_sectionIndex;
//    }
//    else {
//        output = self.imp_sectionIndex;
//    }
//    
//    return output;
    
    // Create a "dummy" index with only bullet points. User can use the bar to quickly jump around the table, but the bar does not show section headers
    NSMutableArray *arrayBuilder = [[NSMutableArray alloc]init];
    int numberOfDummySections = 100;
    for (int index = 0; index < numberOfDummySections; index++) {
        [arrayBuilder addObject:@"\u25C9"];
    }
    
    NSArray *output = [arrayBuilder copy];
    
    return output;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSUInteger numberOfRealSections = [self.tableData count];
    NSArray *dummyArray = [self sectionIndexTitlesForTableView:tableView];
    NSUInteger numberOfDummySections = [dummyArray count];
    double ratio = (double)numberOfRealSections / numberOfDummySections;
    
    NSUInteger realIndexToReturn = (int)(index * ratio); // Conversion to int truncates (i.e. rounds down to nearest whole number)
    
    return realIndexToReturn;
    //return [[self sectionIndexTitlesForTableView:tableView] indexOfObject:title];
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.previousSelectionIndexPath = indexPath;
    
    AW_PropertyViewController *nextVC = [[AW_PropertyViewController alloc]initWithShape:self.tableData[indexPath.section][indexPath.row]];
    
    [self.navigationController pushViewController:nextVC animated:YES];
}

#pragma mark - Custom methods

// Shows a flip horizontal animation for the view currently at the top of the navigation stack
-(void)switchImperialMetric
{
    UIViewAnimationOptions flipDirection;
    
    if ([(AW_NavigationController *)self.navigationController isMetric]) {
        // Switched imperial to metric. Flip from left.
        flipDirection = UIViewAnimationOptionTransitionFlipFromLeft;
    }
    else {
        // Switched metric to imperial. Flip from right.
        flipDirection = UIViewAnimationOptionTransitionFlipFromRight;
    }
    
    // Reload view
    [UIView transitionWithView:self.view duration:0.6 options:flipDirection animations:
     ^{
         [self.tableView reloadData];
     } completion:nil];
}

@end
