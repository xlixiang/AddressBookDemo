//
//  MyTableViewCell.h
//  AddressBookDemo
//
//  Created by xlx on 15/3/28.
//  Copyright (c) 2015年 xlx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *myImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *numberLabel;
@end
