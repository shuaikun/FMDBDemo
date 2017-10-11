//
//  FMDBObject.m
//  FMDBDemo
//
//  Created by caoshuaikun on 2017/5/19.
//  Copyright © 2017年 useeinfo. All rights reserved.
//

#import "FMDBObject.h"

static FMDBObject * fmdb = nil;
@implementation FMDBObject

+ (FMDBObject *)shareFMDBManage {
    if (!fmdb) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            fmdb = [[self alloc] init];
        });
    }
    return fmdb;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self creatFmdb];
    }
    return self;
}

//写入沙盒
+ (void)writeToDocument:(id)file strPath:(NSString *)strPath{
    
    NSString * filePath = [self getDocumentFilePath:strPath];
    if ([UIImageJPEGRepresentation(file, 1.0) writeToFile:filePath options:NSDataWritingAtomic error:nil]) {
        NSLog(@" 写入沙盒成功路径: %@",filePath);
    } else {
        NSLog(@" 写入沙盒失败 %@",filePath);
    }
}

//document路径
+ (NSString *)getDocumentFilePath:(NSString *)strPath {
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString * filePath = [path stringByAppendingPathComponent:strPath];
    return filePath;
}

////升级数据库
//- (void)upgradeDataBaseVesion:(NSString *)dataBasePath {
//    FMDBMigrationManager * manage = [FMDBMigrationManager managerWithDatabaseAtPath:dataBasePath migrationsBundle:[NSBundle mainBundle]];
//     
//    BOOL resultState = NO;
//    NSError * error = nil;
//    if (!manage.hasMigrationsTable) {
//        resultState = [manage createMigrationsTable:&error];
//    }
//    resultState = [manage migrateDatabaseToVersion:UINT64_MAX progress:nil error:&error];
//}

//删除文件
-(void)deleteFile:(NSString *)deletFile {
    
    NSFileManager* fileManager=[NSFileManager defaultManager];
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES).firstObject;
    
    //文件 完整路径
    NSString *uniquePath=[path stringByAppendingPathComponent:@"pin.png"];
    BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:uniquePath];
    
    //判断是否存在
    if (!blHave) {
        
        NSLog(@" 不存在 ");
        return;
    }else {
        
        BOOL blDele= [fileManager removeItemAtPath:uniquePath error:nil];
        if (blDele) {
            NSLog(@" 删除成功 ");
        } else {
            NSLog(@" 删除失败 ");
        }
    }
}

//创建
- (void)creatFmdb {
    
    //1.获得数据库文件的路径
    NSString *doc =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES)  lastObject];
    NSString *fileName = [doc stringByAppendingPathComponent:@"student.db"];
    
    //创建数据库
    self.db = [FMDatabase databaseWithPath:fileName];
    [self.db open];
    NSString * sqlStr = @"create table if not exists Student_Messge (id integer primary key autoincrement, name text not null, age integer not null, sex text not null);";
    
    [self.db setUserVersion:1];
    NSLog(@" 数据库版本号 %d",self.db.userVersion);
    
    BOOL result = [self.db executeUpdate:sqlStr];
    
    //成功与否
    if (!result) {
        NSLog(@"创建表失败");
    }
    [self.db close];
}

//
- (void)addNewfFieldToSqlite:(NSString *)newField data:(NSString *)data{
    
    if (![self.db open]) {
        NSLog(@"数据库打开失败");
    }
    
    if (![self.db columnExists:newField inTableWithName:@"Student_Messge"]) {
        
        NSString *sql = [NSString stringWithFormat:@"alter table Student_Messge ADD %@ text",newField];//这是给一张F名为人的表增加一个age字段
        if ([self.db executeUpdate:sql]) {
            NSLog(@"添加成功");
        }
    }
}

//增
- (void)addDataToFmdb:(StudentModel *)student {
    
    //打开失败
    if (![self.db open]) {
        return;
    }
    BOOL sucessce = [self.db executeUpdate:@"insert into Student_Messge (name, age, sex, adress) values (?,?,?,?);",student.name,@(student.age),student.sex,student.adress];
    
    //如果还没有添加地址的话
    if (!sucessce) {
        sucessce = [self.db executeUpdate:@"insert into Student_Messge (name, age, sex) values (?,?,?);",student.name,@(student.age),student.sex];
        if (!sucessce) {
            NSLog(@" 添加信息失败 ");
        }
    }
    [self.db close];
}

//删
- (void)deleteDataToFmdb:(NSString *)name {
    
    if (![self.db open]) {
        self.db = nil;
        return;
    }
    //1.不确定的参数用？来占位 （后面参数必须是oc对象,需要将int包装成OC对象）
    BOOL sucessce = [self.db executeUpdate:@"delete from Student_Messge where name = ?;",name];
    if (!sucessce) {
        NSLog(@" 数据库删除失败 ");
    }
    [self.db close];
    
    //    //2.不确定的参数用%@，%d等来占位
    //    [self.db executeUpdateWithFormat:@"delete from Student_Messge where name = %@;",@"apple_name"];
}

//改
- (void)chengeDataToFmdb:(NSString *)name newName:(NSString *)newName {
    
    if (![self.db open]) {
        self.db = nil;
        return;
    }
    //修改学生的名字
    BOOL sucessce = [self.db executeUpdate:@"update Student_Messge set name = ? where name = ?",newName,name];
    
    if (!sucessce) {
        NSLog(@" 名字修改失败 ");
    }
    
    [self.db close];
}

//查
- (NSMutableArray *)querayDataToFmdb {
    
    if (![self.db open]) {
        self.db = nil;
        return nil;
    }
    //根据条件查询 现在查询的是所有的信息 条件自己添加
    FMResultSet *resultSet = [self.db executeQuery:@"select * from Student_Messge;"];
    NSMutableArray * mutbaleArray = [NSMutableArray array];
    //遍历结果集合
    while ([resultSet  next]) {
        NSString * name = [resultSet objectForColumnName:@"name"];
        NSString * sex = [resultSet objectForColumnName:@"sex"];
        int age = [resultSet intForColumn:@"age"];
        NSString * adress = [resultSet objectForColumnName:@"adress"];
        StudentModel * model = [[StudentModel alloc] init];
        model.name = name;
        model.sex = sex;
        model.age = age;
        model.adress = adress;
        [mutbaleArray addObject:model];
    }
    return mutbaleArray;
}

@end
