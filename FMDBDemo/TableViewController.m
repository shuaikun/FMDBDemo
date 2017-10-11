//
//  TableViewController.m
//  FMDBDemo
//
//  Created by caoshuaikun on 2017/5/19.
//  Copyright © 2017年 useeinfo. All rights reserved.
//

#import "TableViewController.h"
#import "StudentModel.h"
#import "FMDBObject.h"

@interface TableViewController ()

@property (nonatomic, strong) NSArray * array;

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.array.count;
} 

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    StudentModel * model = self.array[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"姓名:%@ - 年龄:%zd - 性别:%@ - 地址:%@",model.name,model.age,model.sex,model.adress];
    return cell;
}
//删除
- (IBAction)deletAction:(id)sender {
 
    [[FMDBObject shareFMDBManage] deleteDataToFmdb:@"sk"];
    [self getAllDatebaseMessege];
}
//添加
- (IBAction)addAction:(id)sender {
    
    StudentModel * student = [[StudentModel alloc] init];
    student.name = @"sk";
    student.age = 18;
    student.sex = @"男";
    student.adress = @"河南";
    [[FMDBObject shareFMDBManage] addDataToFmdb:student];
    [self getAllDatebaseMessege];
}
//修改
- (IBAction)chengePersonMessge:(id)sender {
    
    [[FMDBObject shareFMDBManage] chengeDataToFmdb:@"sk" newName:@"shuaikun"];
    [self getAllDatebaseMessege];
}
- (IBAction)addNewFiledAction:(id)sender {
    [[FMDBObject shareFMDBManage] addNewfFieldToSqlite:@"adress" data:@"商丘"];
    [self getAllDatebaseMessege];
}
- (void)getAllDatebaseMessege {
    
    NSArray * array = [[FMDBObject shareFMDBManage] querayDataToFmdb];
    self.array = array;
    [self.tableView reloadData];
}


#pragma mark - viewWillAppear
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.array = [[FMDBObject shareFMDBManage] querayDataToFmdb];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
