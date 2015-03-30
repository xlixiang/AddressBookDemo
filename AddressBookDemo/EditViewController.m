//
//  EditViewController.m
//  AddressBookDemo
//
//  Created by xlx on 15/3/26.
//  Copyright (c) 2015年 xlx. All rights reserved.
//

#import "EditViewController.h"
#import "Person.h"
#import "NSString+FirstLetter.h"

@interface EditViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *numberTextField;
@property (strong, nonatomic) IBOutlet UIButton *imageButton;

//声明CoreData的上下文
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
//头像获得
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@end

@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //通过application对象的代理对象获取上下文
    UIApplication *application = [UIApplication sharedApplication];
    id delegate = application.delegate;
    self.managedObjectContext = [delegate managedObjectContext];
    
    //如果为修改信息，则显示segue穿过老的信息
    if (self.person != nil) {
        self.nameTextField.text = self.person.name;
        self.numberTextField.text = self.person.number;
        
        if (self.person.imageData != nil) {
            UIImage *image = [UIImage imageWithData:self.person.imageData];
            [self.imageButton setImage:image forState:UIControlStateNormal];
        }
    }
    
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.allowsEditing = YES;
    self.imagePicker.delegate = self;
}
- (IBAction)saveTap:(id)sender {
    //如果person为空，即不是从cell进到本界面，则创建
    if (self.person == nil) {
        self.person = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Person class]) inManagedObjectContext:self.managedObjectContext];
    }
    
    //给Person赋值
    self.person.name = self.nameTextField.text;
    self.person.number = self.numberTextField.text;
    self.person.firstN = [NSString stringWithFormat:@"%s",[[self.person.name firstLetter] UTF8String]];
    
    UIImage *personImage = [self.imageButton imageView].image;
    self.person.imageData = UIImagePNGRepresentation(personImage);
    
    //通过上下文存储实体对象
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"%@",[error localizedDescription]);
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (IBAction)tapImageButton:(id)sender {
    [self presentViewController:self.imagePicker animated:YES completion:^{
        
    }];
}

//UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    [self.imageButton setImage:image forState:UIControlStateNormal];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
