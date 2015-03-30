//
//  ViewController.m
//  AddressBookDemo
//
//  Created by xlx on 15/3/26.
//  Copyright (c) 2015年 xlx. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import "MyTableViewCell.h"
#import "SearchTableViewCell.h"

@interface ViewController ()
//声明通过CoreData读取数据要用到的变量
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
//用来存储查询并适合TableView来显示的数据
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) IBOutlet UISearchBar *searchVC;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *displayVC;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIApplication *application = [UIApplication sharedApplication];
    id delegate = application.delegate;
    self.managedObjectContext = [delegate managedObjectContext];
    
    //通过CoreData获取sqlite中的数据
    //通过实体名获取请求
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([Person class])];
    
    //定义分组和排序规则
    NSSortDescriptor *soryDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstN" ascending:YES];
    
    //把排序和分组规则添加到请求中
    [request setSortDescriptors:@[soryDescriptor]];
    
    //把请求的结果转换成适合TableView显示的数据
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"firstN" cacheName:nil];
    
    //执行fetchedResultsController
    NSError *error;
    if ([self.fetchedResultsController performFetch:&error]) {
        NSLog(@"%@",[error localizedDescription]);
    }
    
    self.fetchedResultsController.delegate = self;
}
//NSFetchedResultsControllerDelegate
//当CoreData的数据正在发生改变时，FRC产生的回调
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

//分区改变状况
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            break;
    }
}
//数据改变状况
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            //让tableView在newIndexPath位置插入一个cell
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            //让tableView刷新indexPath上得cell
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

//UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sections = [self.fetchedResultsController sections];
    id<NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:self.displayVC.searchResultsTableView]) {
        SearchTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"searchCell" forIndexPath:indexPath];
        
        Person *person = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        cell.nameLabel.text = person.name;
        cell.numberLabel.text = person.number;
        
        
        if (person.imageData != nil) {
            UIImage *image = [UIImage imageWithData:person.imageData];
            cell.myImageView.image = image;
        }
        else {
            cell.myImageView.image = [UIImage imageNamed:@"headImage"];
        }
        
        return cell;
    }

    MyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addressCell" forIndexPath:indexPath];
    
    Person *person = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.nameLabel.text = person.name;
    cell.numberLabel.text = person.number;
    
    
    if (person.imageData != nil) {
        UIImage *image = [UIImage imageWithData:person.imageData];
        cell.myImageView.image = image;
    }
    else {
        cell.myImageView.image = [UIImage imageNamed:@"headImage"];
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSArray *sections = [self.fetchedResultsController sections];
    return sections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *sections = [self.fetchedResultsController sections];
    id<NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    return [sectionInfo name];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //通过CoreData删除对象，通过indexPath获取要删除的实体
        Person *person = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        //通过上下文移除
        [self.managedObjectContext deleteObject:person];
        
        //保存
        NSError *error;
        if ([self.managedObjectContext save:&error]) {
            NSLog(@"shanchu%@",[error localizedDescription]);
        }
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSArray *sectionArray = [self.fetchedResultsController sections];
    NSMutableArray *index = [NSMutableArray arrayWithCapacity:sectionArray.count];
    
    //循环获取每个section的header，
    for (int i=0; i<sectionArray.count; i++) {
        id<NSFetchedResultsSectionInfo> info = sectionArray[i];
        [index addObject:[info name]];
    }
    
    return index;
}

//UITableViewDelegate
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 82;
}
//segue把对应的cell上得值穿到修改的页面上
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //判断sender是否为TableViewCell对象
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        MyTableViewCell *cell = (MyTableViewCell *)sender;
        
        //通过tableView获取cell对应的索引，通过索引获取实体对象
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        //使用frc通过indexPath获取Person
        Person *person = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        //通过segue来获取我们的目的试图控制器
        UIViewController *nextView = [segue destinationViewController];
        
        //通过KVC把参数传入目的控制器
        [nextView setValue:person forKey:@"person"];
    }
}

//UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    //新建查询语句
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([Person class])];
    
    //排序规则
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstN" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    
    //添加谓词
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains %@",searchText];
    [request setPredicate:predicate];
    
    //将查询结果存入fetchedResultsController
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"firstN" cacheName:nil];
    
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"%@",[error localizedDescription]);
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar; {
    [self viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
