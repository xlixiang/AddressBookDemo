//
//  ViewController.h
//  AddressBookDemo
//
//  Created by xlx on 15/3/26.
//  Copyright (c) 2015年 xlx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#define SYSTEMVERSION [[UIDevice currentDevice].systemVersion floatValue]

@interface ViewController : UIViewController<NSFetchedResultsControllerDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;


@end

