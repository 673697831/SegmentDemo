//
//  APEncryptDatabaseQueue.h
//  APSQLCipher
//
//  Created by ozr on 16/8/10.
//  Copyright © 2016年 ozr. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;

@interface APEncryptDatabaseQueue : NSObject

+ (instancetype)databaseQueueWithPath:(NSString*)aPath encryptKey:(NSString *)encryptKey;

- (instancetype)initWithPath:(NSString*)aPath encryptKey:(NSString *)encryptKey;

- (void)inDatabase:(void (^)(FMDatabase *db))block;

- (void)inTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block;

- (void)close;

@end
