//
//  APEncryptDatabaseQueue.m
//  APSQLCipher
//
//  Created by ozr on 16/8/10.
//  Copyright © 2016年 ozr. All rights reserved.
//

#import "APEncryptDatabaseQueue.h"
#if __has_include(<FMDB/FMDB.h>)
#import <FMDB/FMDB.h>
#else
#import "FMDB.h"
#endif

@interface APDatabaseQueue : FMDatabaseQueue

+ (instancetype)databaseQueueWithPath:(NSString*)aPath encryptKey:(NSString *)encryptKey;

@end

@implementation APDatabaseQueue

+ (instancetype)databaseQueueWithPath:(NSString*)aPath encryptKey:(NSString *)encryptKey
{
    APDatabaseQueue *queue = [self databaseQueueWithPath:aPath];
    if (queue && encryptKey) {
        [queue->_db setKey:encryptKey];
    }
    
    queue->_db.shouldCacheStatements = YES;
    
    FMDBAutorelease(queue);
    
    return queue;
}

@end

@interface APEncryptDatabaseQueue ()

@property (nonatomic, strong) APDatabaseQueue *dbQueue;

@end

@implementation APEncryptDatabaseQueue

+ (instancetype)databaseQueueWithPath:(NSString*)aPath encryptKey:(NSString *)encryptKey
{
    return [[self alloc] initWithPath:aPath encryptKey:encryptKey];
}

- (instancetype)initWithPath:(NSString*)aPath encryptKey:(NSString *)encryptKey
{
    if (self = [self init]) {
        _dbQueue = [APDatabaseQueue databaseQueueWithPath:aPath encryptKey:encryptKey];
    }
    
    return self;
}

- (void)inDatabase:(void (^)(FMDatabase *db))block
{
    return [self.dbQueue inDatabase:block];
}

- (void)inTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block
{
    return [self.dbQueue inTransaction:block];
}

- (void)close
{
    [self.dbQueue close];
}

@end
