//
//  Person.h
//  AddressBookDemo
//
//  Created by xlx on 15/3/26.
//  Copyright (c) 2015年 xlx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Person : NSManagedObject

@property (nonatomic, retain) NSString * firstN;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSData * imageData;

@end
