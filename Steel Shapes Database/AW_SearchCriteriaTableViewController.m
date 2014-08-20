//
//  AW_SearchCriteriaTableViewController.m
//  Shape DB
//
//  Created by Alan Wang on 7/21/14.
//  Copyright (c) 2014 Alan Wang. All rights reserved.
//

#import "AW_SearchCriteriaTableViewController.h"
#import "AW_ShapeFamily.h"
#import "AW_PropertyCriteriaObject.h"
#import "AW_PropertyDescription.h"
#import "AW_AddPropertyCriteriaViewController.h"
#import "AW_PropertyCriteriaTableViewCell.h"
#import "AW_NavigationController.h"

@interface AW_SearchCriteriaTableViewController ()

@end

@implementation AW_SearchCriteriaTableViewController

#pragma mark - Custom accessors

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set up navigation bar stuff
    // Set database title for navigation bar
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:17.0];   //Matches Apple's default nav bar title font
    titleLabel.textColor = self.navigationController.navigationBar.tintColor;
    titleLabel.text = @"Search By Property";
    [titleLabel sizeToFit];
    
    self.navigationItem.titleView = titleLabel;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(clearAllCriteria)];
    
    // Set up table view stuff
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"AW_PropertyCriteriaTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"AW_PropertyCriteriaTableViewCell"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Change colors
    self.navigationController.navigationBar.barTintColor = self.databaseCriteria.backgroundColor;
    self.navigationController.navigationBar.tintColor = self.databaseCriteria.textColor;
    ((UILabel *)self.navigationItem.titleView).textColor = self.databaseCriteria.textColor;
    self.tabBarController.tabBar.barTintColor = self.databaseCriteria.backgroundColor;
    self.tabBarController.tabBar.tintColor = self.databaseCriteria.textColor;
        
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.databaseCriteria) {
        return 1;   // Return only the database criteria section
    }
    else if (!self.shapeFamilyCriteria) {
        return 2;   // Return database criteria section and shape family section
    }
    else if (!self.propertyCriteria) {
        return 3;   // Return database criteria, shape family criteria, and property criteria sections
    }
    else {
        return 4;   // All criteria have been filled. Final section contains the Search button.
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // DATABASE SECTION
    if (section == 0) {
        // Database section
        return 1;
    }
    
    // SHAPE FAMILY SECTION
    else if (section == 1)
    {
        // Shape family section
        if (!self.shapeFamilyCriteria) {
            return 1;   // Return a cell allowing selection of shape families
        }
        else {
            return [self.shapeFamilyCriteria count];
        }
        
    }
    
    // PROPERTY CRITERIA SECTION
    else if (section == 2)
    {
        if (!self.propertyCriteria) {
            return 1;   // Return a cell allowing addition of property criteria
        }
        else {
            return [self.propertyCriteria count];
        }
    }
    
    // SEARCH BUTTON
    else if (section == 3) {
        return 1;   //Search button cell
    }
    
    else {
        // Unrecognized section
        [NSException raise:@"Unrecognized section number" format:@"Unrecognized section number sent ot numberOfRowsInSection"];
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    NSUInteger section = indexPath.section;
    
    // DATABASE CRITERIA
    // Note: We need to set the image every time, because cells are not removed from memory when the Clear button is pressed.
    if (section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
        
        if (!self.databaseCriteria) {
            cell.textLabel.text = @"Select Database";
            cell.imageView.image = nil;
        }
        else {
            cell.textLabel.text = self.databaseCriteria.longName;
            cell.imageView.image = nil;
        }
    }
    
    // SHAPE FAMILY CRITERIA
    else if (section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
        
        if (!self.shapeFamilyCriteria) {
            // If no shape families selected, present cell to select them
            cell.textLabel.text = @"Select Shape(s)";
            cell.imageView.image = nil;
        }
        else {
            // Display the titles and images of each shape family selected
            AW_ShapeFamily *shapeFamily = self.shapeFamilyCriteria[indexPath.row];
            cell.textLabel.text = shapeFamily.displayName;
            cell.imageView.image = shapeFamily.image;
        }
    }
    
    // PROPERTY CRITERIA
    else if (section == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"AW_PropertyCriteriaTableViewCell" forIndexPath:indexPath];
        
        if (!self.propertyCriteria) {
            // If no property criteria are present, present cell to select them
            cell.textLabel.text = @"Add Search Criteria";
            cell.imageView.image = nil;
        }
        else {
            // Display property criteria
            cell.textLabel.text = nil;
            AW_PropertyCriteriaObject *propertyCriteriaObject = self.propertyCriteria[indexPath.row];
            AW_PropertyCriteriaTableViewCell *propertyCriteriaCell = (AW_PropertyCriteriaTableViewCell *)cell;
            propertyCriteriaCell.symbolLabel.attributedText = [propertyCriteriaObject symbol];
            propertyCriteriaCell.relationshipLabel.text = [propertyCriteriaObject relationshipSymbol];
            propertyCriteriaCell.valueLabel.text = [NSString stringWithFormat:@"%@", propertyCriteriaObject.value];
            propertyCriteriaCell.unitsLabel.text = [propertyCriteriaObject units];
        }
    }
    
    // SEARCH BUTTON
    else if (section == 3) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
        
        cell.textLabel.text = @"Search...";
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Database";
    }
    else if (section == 1) {
        return @"Shape(s)";
    }
    else if (section == 2) {
        return @"Property";
    }
    else {
        return nil;
    }
}

#pragma mark - Table View Delegate Methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = indexPath.section;
    
    // DATABASE CRITERIA
    if (section == 0) {
        AW_DatabaseSelectorModalTableViewController *modalVC = [[AW_DatabaseSelectorModalTableViewController alloc]initWithStyle:UITableViewStylePlain];
        modalVC.searchCriteriaVC = self;
        UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:modalVC];
        [self presentViewController:navController animated:YES completion:nil];
    }
    
    // SHAPE FAMILY CRITERIA
    else if (section == 1) {
        // Present Shape Family Modal Selector
        AW_ShapeFamilySelectorModalTableViewController *modalVC = [[AW_ShapeFamilySelectorModalTableViewController alloc]initWithStyle:UITableViewStyleGrouped];
        modalVC.searchCriteriaVC = self;
        
        // Embed a navigation controller for the nav bar
        UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:modalVC];
        
        [self presentViewController:navController animated:YES completion:nil];
    }
    
    // PROPERTY CRITERIA
    else if (section == 2) {

        AW_AddPropertyCriteriaViewController *modalVC = [[AW_AddPropertyCriteriaViewController alloc]initWithNibName:@"AW_AddPropertyCriteriaViewController" bundle:[NSBundle mainBundle]];
        
        modalVC.searchCriteriaVC = self;
        
        if (self.propertyCriteria) {
            modalVC.criteria = self.propertyCriteria[indexPath.row];
        }
        
        AW_NavigationController *navController = [[AW_NavigationController alloc]initWithRootViewController:modalVC];
        
        [self presentViewController:navController animated:YES completion:nil];

    }
    
    // SEARCH BUTTON
    else if (section == 3) {
    }
}

#pragma mark - Helper methods
- (void)clearAllCriteria
{
    self.databaseCriteria = nil;
    self.shapeFamilyCriteria = nil;
    self.propertyCriteria = nil;

#warning TODO - find a way to soften the transition
    [self.tableView reloadData];
    [self viewWillAppear:YES];  // Reset nav bar colors
 
}

#pragma mark - Delegate methods
-(void)databaseSelectorDidChangeDatabase
{
    self.shapeFamilyCriteria = nil;
    self.propertyCriteria = nil;
    
    [self.tableView reloadData];
}

-(void)shapeFamilySelectorDidRemoveShapeFamily
{
    NSMutableArray *propertyCriteriaCollection = [self.propertyCriteria mutableCopy];
    
    NSSet *selectedShapeFamilies = [NSSet setWithArray:self.shapeFamilyCriteria];

    // For each property criteria object
    for (AW_PropertyCriteriaObject *propertyCriteria in propertyCriteriaCollection) {
        
        // If none of the selected shape families contain this property, then remove it from the property criteria colelction
        if (![propertyCriteria.propertyDescription.shapeFamilies intersectsSet:selectedShapeFamilies]) {
            [propertyCriteriaCollection removeObject:propertyCriteria];
        }
    }
    
    if ([propertyCriteriaCollection count] == 0) {
        self.propertyCriteria = nil;
    }
    else {
        self.propertyCriteria = [propertyCriteriaCollection copy];
    }
}

@end
