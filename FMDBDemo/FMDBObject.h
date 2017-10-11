//
//  FMDBObject.h
//  FMDBDemo
//
//  Created by caoshuaikun on 2017/5/19.
//  Copyright © 2017年 useeinfo. All rights reserved.
//

#import <Foundation/Foundation.h> 
#import <UIKit/UIKit.h>
#import "FMDB.h"
#import "StudentModel.h"
#import <FMDBMigrationManager.h>

@interface FMDBObject : NSObject

@property (nonatomic, strong) FMDatabase * db;

+ (FMDBObject *)shareFMDBManage;

//写入沙盒
+ (void)writeToDocument:(id)file strPath:(NSString *)strPath;
+ (NSString *)getDocumentFilePath:(NSString *)strPath;

//fmdb使用
- (void)addNewfFieldToSqlite:(NSString *)newField data:(NSString *)data;
- (void)creatFmdb;
- (void)addDataToFmdb:(StudentModel *)student;
- (void)deleteDataToFmdb:(NSString *)name;
- (void)chengeDataToFmdb:(NSString *)name newName:(NSString *)newName;
- (NSMutableArray *)querayDataToFmdb;

@end
