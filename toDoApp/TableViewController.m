//
//  TableViewController.m
//  toDoApp
//
//  Created by Eugenia Leong on 12/15/13.
//  Copyright (c) 2013 Eugenia Leong. All rights reserved.
//

#import "TableViewController.h"
#import "EditableCell.h"
#import <objc/runtime.h>

@interface TableViewController ()

@end
static NSString *tag = @"CellTag";

NSString * const CELL_IDENTIFIER = @"EditableCell";
NSMutableArray *itemsList;
UIBarButtonItem *addButtonItem;
UIBarButtonItem *editButtonItem;
UIBarButtonItem *doneButtonItem;

@implementation TableViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"To Do List";
        addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)];
        editButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit:)];
        
        doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];

        [self setNavigationItemsInDisplayMode];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    itemsList = [[NSMutableArray alloc]init];
    
    UINib *customNib = [UINib nibWithNibName:CELL_IDENTIFIER bundle:nil];
    [self.tableView registerNib:customNib forCellReuseIdentifier:CELL_IDENTIFIER];

    // don't need! UIKeyboardDidHideNotification was causing newly created cell to resignFirstResponder!
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(keyboardShown:)
                                          name:UIKeyboardDidShowNotification
                                          object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(keyboardHidden:)
                                          name:UIKeyboardDidHideNotification
                                          object:nil];
     */

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [itemsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EditableCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    
    // Configure the cell...
    cell.cellContent.text = [itemsList objectAtIndex:indexPath.row];
    objc_setAssociatedObject(cell.cellContent, &tag, cell, OBJC_ASSOCIATION_RETAIN);
    cell.cellContent.delegate = self;
    return cell;
}

-(IBAction)done:(id)sender
{
    [self setNavigationItemsInDisplayMode];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    EditableCell *cell = objc_getAssociatedObject(textField, &tag);
    /*
    // debug
    NSString *s = cell.cellContent.text;
    NSLog(@"textFieldDidEndEditing %@", s);
    */
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self save:indexPath];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self setNavigationItemsInAddMode];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    
    return YES;
}

-(IBAction)add:(id)sender
{
    // add new item, can't be empty string, it causes error
    [itemsList addObject:@" "];
    
    // update table view
    [self.tableView reloadData];
    
    // get cell that was just added and open keyboard
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[itemsList count]-1 inSection:0];
    EditableCell *newCell = (EditableCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    /*
    // debug
    NSString *s = newCell.cellContent.text;
    NSLog(@"added %@", s);
    */
    
    [newCell.cellContent becomeFirstResponder];
    
    [self setNavigationItemsInAddMode];
}


-(IBAction)edit:(id)sender
{
    [self setNavigationItemsInEditMode];
}

-(void)save:(NSIndexPath*)indexPath
{
    EditableCell *cell = (EditableCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    NSString *trimmed = [cell.cellContent.text stringByTrimmingCharactersInSet:
                         [NSCharacterSet whitespaceCharacterSet]];
    // don't save if user didn't type anything
    if ([trimmed length] == 0)
    {
        if (indexPath.row < [itemsList count])
        {
            [itemsList removeObjectAtIndex:indexPath.row];
        }

    }
    else
    {
        [itemsList replaceObjectAtIndex:indexPath.row withObject:cell.cellContent.text];
    }
}

-(void)setNavigationItemsInEditMode
{
    self.navigationItem.rightBarButtonItem = doneButtonItem;
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
    self.tableView.editing = YES;

};

-(void)setNavigationItemsInAddMode
{
    self.navigationItem.rightBarButtonItem = addButtonItem;
    self.navigationItem.leftBarButtonItem = doneButtonItem;
    
};

-(void)setNavigationItemsInDisplayMode
{
    self.navigationItem.leftBarButtonItem = editButtonItem;
    self.navigationItem.rightBarButtonItem = addButtonItem;
    if ([itemsList count] == 0)
    {
        [self.navigationItem.leftBarButtonItem setEnabled:NO];
    }
    else
    {
        [self.navigationItem.leftBarButtonItem setEnabled:YES];
    }

    [self.view endEditing:YES];
    self.tableView.editing = NO;
}
/*
- (void)keyboardShown: (NSNotification *) notif{
    [self setNavigationItemsInAddMode];
}

- (void)keyboardHidden: (NSNotification *) notif{
    [self setNavigationItemsInDisplayMode];
}
*/


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // delete item from itemsList first so numberOfRowsInSection will have correct return value in deleteRowsAtIndexPaths
        [itemsList removeObjectAtIndex:indexPath.row];
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView reloadData];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSString *item = [itemsList objectAtIndex:fromIndexPath.row];
    [itemsList removeObject: item];
    [itemsList insertObject: item atIndex:toIndexPath.row];
    [tableView reloadData];
}

/*
- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self save:indexPath];
    [self.tableView reloadData];
    [self setNavigationItemsInDisplayMode];
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

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
