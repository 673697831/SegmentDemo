//
//  APKeyValueStore.h
//  APSQLCipher
//
//  Created by ozr on 16/8/10.
//  Copyright © 2016年 ozr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APKeyValueStore : NSObject

+ (BOOL)checkTableName:(NSString *)tableName;

+ (instancetype)storeWithDBPath:(NSString *)dbPath
                     encryptKey:(NSString *)encryptKey;

- (void)createTableWithName:(NSString *)tableName;

- (BOOL)isTableExists:(NSString *)tableName;

- (void)clearTable:(NSString *)tableName;

- (void)close;

#pragma mark -

//object必须是array或者dictionary
- (BOOL)putObject:(id)object withId:(NSString *)objectId intoTable:(NSString *)tableName;

//返回的必须是array或者dictionary
- (id)getObjectById:(NSString *)objectId fromTable:(NSString *)tableName;

- (BOOL)putString:(NSString *)string withId:(NSString *)stringId intoTable:(NSString *)tableName;

- (NSString *)getStringById:(NSString *)stringId fromTable:(NSString *)tableName;

- (BOOL)putNumber:(NSNumber *)number withId:(NSString *)numberId intoTable:(NSString *)tableName;

- (NSNumber *)getNumberById:(NSString *)numberId fromTable:(NSString *)tableName;

- (NSArray *)getAllItemObjectsFromTable:(NSString *)tableName;

- (NSUInteger)getCountFromTable:(NSString *)tableName;

- (BOOL)deleteObjectById:(NSString *)objectId fromTable:(NSString *)tableName;

- (BOOL)deleteObjectsByIdArray:(NSArray *)objectIdArray fromTable:(NSString *)tableName;

- (void)deleteObjectsByIdPrefix:(NSString *)objectIdPrefix fromTable:(NSString *)tableName;

- (BOOL)insertObjectsByIdArray:(NSArray *)objectIdArray withArray:(NSArray<NSDictionary *> *)array fromTable:(NSString *)tableName;

- (id)getObjectById:(NSString *)objectId fromTable:(NSString *)tableName afterDate:(NSDate *)date;

- (NSArray *)getAllItemObjectsFromTable:(NSString *)tableName afterDate:(NSDate *)date;

- (void)deleteObjectWithObjectById:(NSString *)objectId fromTable:(NSString *)tableName beforeDate:(NSDate *)date;

- (void)deleteObjectFromTable:(NSString *)tableName beforeDate:(NSDate *)date;

@end
