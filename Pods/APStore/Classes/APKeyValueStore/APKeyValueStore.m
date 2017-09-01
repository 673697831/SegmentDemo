//
//  APKeyValueStore.m
//  APSQLCipher
//
//  Created by ozr on 16/8/10.
//  Copyright © 2016年 ozr. All rights reserved.
//

#import "APKeyValueStore.h"
#import "APEncryptDatabaseQueue.h"
#import "APKeyValueStoreDef.h"
#import "APKeyValueItem.h"
#if __has_include(<FMDB/FMDB.h>)
#import <FMDB/FMDB.h>
#else
#import "FMDB.h"
#endif

@interface APKeyValueStore ()

@property (nonatomic, copy) NSString *encryptKey;
@property (nonatomic, strong) APEncryptDatabaseQueue *dbQueue;

@end

@implementation APKeyValueStore

+ (BOOL)checkTableName:(NSString *)tableName
{
    if (tableName == nil || tableName.length == 0 || [tableName rangeOfString:@" "].location != NSNotFound) {
        NSLog(@"ERROR, table name: %@ format error.", tableName);
        return NO;
    }
    return YES;
}

+ (instancetype)storeWithDBPath:(NSString *)dbPath
                     encryptKey:(NSString *)encryptKey
{ 
    return [[self alloc] initWithDBWithPath:dbPath encryptKey:encryptKey];
}

- (instancetype)initWithDBWithPath:(NSString *)dbPath
                        encryptKey:(NSString *)encryptKey
{
    if (self = [self init]) {
        _encryptKey = [encryptKey copy];
        _dbQueue = [APEncryptDatabaseQueue databaseQueueWithPath:dbPath encryptKey:encryptKey];
    }
    
    return self;
}

- (void)createTableWithName:(NSString *)tableName
{
    if ([APKeyValueStore checkTableName:tableName] == NO) {
        return;
    }
    NSString * sql = [NSString stringWithFormat:CREATE_TABLE_SQL, tableName];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];
    if (!result) {
        NSLog(@"ERROR, failed to create table: %@", tableName);
    }
}

- (BOOL)isTableExists:(NSString *)tableName
{
    if ([APKeyValueStore checkTableName:tableName] == NO) {
        return NO;
    }
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db tableExists:tableName];
    }];
    if (!result) {
        NSLog(@"ERROR, table: %@ not exists in current DB", tableName);
    }
    return result;
}

- (void)clearTable:(NSString *)tableName
{
    if ([APKeyValueStore checkTableName:tableName] == NO) {
        return;
    }
    NSString * sql = [NSString stringWithFormat:CLEAR_ALL_SQL, tableName];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];
    if (!result) {
        NSLog(@"ERROR, failed to clear table: %@", tableName);
    }
}

- (void)close
{
    [_dbQueue close];
    _dbQueue = nil;
}

#pragma mark -

- (BOOL)putObjectWithDictionary:(NSDictionary *)dictionary
                         withId:(NSString *)objectId
                      intoTable:(NSString *)tableName
{
    return [self putObject:dictionary withId:objectId intoTable:tableName];
}

- (NSDictionary *)getRDKeyValueItemDictionaryById:(NSString *)objectId
                                        fromTable:(NSString *)tableName
{
    return [self getObjectById:objectId fromTable:tableName];
}

- (BOOL)putString:(NSString *)string
           withId:(NSString *)stringId
        intoTable:(NSString *)tableName
{
    if (string == nil) {
        NSLog(@"string should not be nil");
        return NO;
    }
    
    return [self putObject:@[string] withId:stringId intoTable:tableName];
}

- (NSString *)getStringById:(NSString *)stringId fromTable:(NSString *)tableName
{
    NSArray * array = [self getObjectById:stringId fromTable:tableName];
    if (array && [array isKindOfClass:[NSArray class]]) {
        return array[0];
    }
    return nil;
}

- (BOOL)putNumber:(NSNumber *)number withId:(NSString *)numberId intoTable:(NSString *)tableName
{
    if (number == nil) {
        NSLog(@"number should not be nil");
        return NO;
    }
    
    return [self putObject:@[number] withId:numberId intoTable:tableName];
}

- (NSNumber *)getNumberById:(NSString *)numberId fromTable:(NSString *)tableName
{
    NSArray * array = [self getObjectById:numberId fromTable:tableName];
    if (array && [array isKindOfClass:[NSArray class]]) {
        return array[0];
    }
    return nil;
}

- (NSArray *)getAllItemObjectsFromTable:(NSString *)tableName
{
    return [self getAllItemObjectsFromTable:tableName afterDate:nil];
}

- (NSUInteger)getCountFromTable:(NSString *)tableName
{
    if ([APKeyValueStore checkTableName:tableName] == NO) {
        return 0;
    }
    
    [self createTableWithName:tableName];
    
    NSString * sql = [NSString stringWithFormat:COUNT_ALL_SQL, tableName];
    __block NSInteger num = 0;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * rs = [db executeQuery:sql];
        if ([rs next]) {
            num = [rs unsignedLongLongIntForColumn:@"num"];
        }
        [rs close];
    }];
    return num;
}

- (BOOL)deleteObjectById:(NSString *)objectId fromTable:(NSString *)tableName {
    if ([APKeyValueStore checkTableName:tableName] == NO) {
        return NO;
    }
    
    [self createTableWithName:tableName];
    
    NSString * sql = [NSString stringWithFormat:DELETE_ITEM_SQL, tableName];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql, objectId];
    }];
    if (!result) {
        NSLog(@"ERROR, failed to delete item from table: %@", tableName);
        return NO;
    }
    
    return YES;
}

- (BOOL)deleteObjectsByIdArray:(NSArray *)objectIdArray fromTable:(NSString *)tableName {
    if ([APKeyValueStore checkTableName:tableName] == NO) {
        return NO;
    }
    
    [self createTableWithName:tableName];
    
    NSMutableString *stringBuilder = [NSMutableString string];
    for (id objectId in objectIdArray) {
        NSString *item = [NSString stringWithFormat:@" '%@' ", objectId];
        if (stringBuilder.length == 0) {
            [stringBuilder appendString:item];
        } else {
            [stringBuilder appendString:@","];
            [stringBuilder appendString:item];
        }
    }
    NSString *sql = [NSString stringWithFormat:DELETE_ITEMS_SQL, tableName, stringBuilder];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];
    if (!result) {
        NSLog(@"ERROR, failed to delete items by ids from table: %@", tableName);
        return NO;
    }
    
    return YES;
}

- (void)deleteObjectsByIdPrefix:(NSString *)objectIdPrefix fromTable:(NSString *)tableName {
    if ([APKeyValueStore checkTableName:tableName] == NO) {
        return;
    }
    
    [self createTableWithName:tableName];
    
    NSString *sql = [NSString stringWithFormat:DELETE_ITEMS_WITH_PREFIX_SQL, tableName];
    NSString *prefixArgument = [NSString stringWithFormat:@"%@%%", objectIdPrefix];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql, prefixArgument];
    }];
    if (!result) {
        NSLog(@"ERROR, failed to delete items by id prefix from table: %@", tableName);
    }
}

- (BOOL)insertObjectsByIdArray:(NSArray *)objectIdArray
                     withArray:(NSArray<NSDictionary *> *)array
                     fromTable:(NSString *)tableName
{
    if ([APKeyValueStore checkTableName:tableName] == NO) {
        return NO;
    }
    
    if (objectIdArray.count != objectIdArray.count) {
        return NO;
    }
    
    [self createTableWithName:tableName];
    
    NSMutableArray *jsonStringArray = [NSMutableArray new];
    for (NSDictionary *dic in array) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&error];
        if (!data) {
            NSLog(@"ERROR, faild to get json data");
            return NO;
        }
        NSString * jsonString = [[NSString alloc] initWithData:data encoding:(NSUTF8StringEncoding)];
        [jsonStringArray addObject:jsonString];
    }
    
    [self createTableWithName:tableName];
    

    NSDate * createdTime = [NSDate date];
    NSString * sql = [NSString stringWithFormat:UPDATE_ITEM_SQL, tableName];
    
    __block BOOL result;
    
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (int i = 0; i < jsonStringArray.count; i ++) {
            NSString *objectId = objectIdArray[i];
            NSString *jsonString = jsonStringArray[i];
            result = [db executeUpdate:sql, objectId, jsonString, createdTime];
            if (!result) {
                *rollback = YES;
                return;
            }
        }
    }];
    
    return YES;
}

- (BOOL)putObject:(id)object withId:(NSString *)objectId intoTable:(NSString *)tableName {
    if ([APKeyValueStore checkTableName:tableName] == NO) {
        return NO;
    }
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
    
    if (!data) {
        NSLog(@"ERROR, faild to get json data");
        return NO;
    }
    
    [self createTableWithName:tableName];
    
    NSString * jsonString = [[NSString alloc] initWithData:data encoding:(NSUTF8StringEncoding)];
    NSDate * createdTime = [NSDate date];
    NSString * sql = [NSString stringWithFormat:UPDATE_ITEM_SQL, tableName];
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql, objectId, jsonString, createdTime];
    }];
    if (!result) {
        NSLog(@"ERROR, failed to insert/replace into table: %@", tableName);
        return NO;
    }
    
    return YES;
}

- (id)getObjectById:(NSString *)objectId fromTable:(NSString *)tableName
{
    return [self getObjectById:objectId fromTable:tableName afterDate:nil];
}

- (id)getObjectById:(NSString *)objectId fromTable:(NSString *)tableName afterDate:(NSDate *)date
{
    APKeyValueItem *item = [self getKeyValueItemById:objectId fromTable:tableName];
    if (!item) {
        return nil;
    }
    if (date && [item.createdTime compare:date] == NSOrderedAscending) {
        return nil;
    }
    
    return item.itemObject;
}

- (NSArray *)getAllItemObjectsFromTable:(NSString *)tableName afterDate:(NSDate *)date
{
    NSArray *allItems = [self getAllKeyValueItemFromTable:tableName];
    if (!allItems) {
        return @[];
    }
    NSMutableArray *allObjects = [NSMutableArray new];
    for (APKeyValueItem *item in allItems) {
        if (!(date && [item.createdTime compare:date] == NSOrderedAscending)) {
            [allObjects addObject:item.itemObject];
        }
    }
    
    return allObjects;
}

- (APKeyValueItem *)getKeyValueItemById:(NSString *)objectId fromTable:(NSString *)tableName
{
    if ([APKeyValueStore checkTableName:tableName] == NO) {
        return nil;
    }
    
    [self createTableWithName:tableName];
    
    NSString * sql = [NSString stringWithFormat:QUERY_ITEM_SQL, tableName];
    __block NSString * json = nil;
    __block NSDate * createdTime = nil;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * rs = [db executeQuery:sql, objectId];
        if ([rs next]) {
            json = [rs stringForColumn:@"json"];
            createdTime = [rs dateForColumn:@"createdTime"];
        }
        [rs close];
    }];
    if (json) {
        NSError * error;
        id result = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:(NSJSONReadingAllowFragments) error:&error];
        if (error) {
            NSLog(@"ERROR, faild to prase to json");
            return nil;
        }
        APKeyValueItem * item = [[APKeyValueItem alloc] init];
        item.itemId = objectId;
        item.itemObject = result;
        item.createdTime = createdTime;

        return item;
    } else {
        return nil;
    }
}

- (NSArray<APKeyValueItem *> *)getAllKeyValueItemFromTable:(NSString *)tableName
{
    if ([APKeyValueStore checkTableName:tableName] == NO) {
        return nil;
    }
    
    [self createTableWithName:tableName];
    
    NSString * sql = [NSString stringWithFormat:SELECT_ALL_SQL, tableName];
    __block NSMutableArray * jsonResult = [NSMutableArray array];
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next]) {
            APKeyValueItem *item = [[APKeyValueItem alloc] init];
            item.itemId = [rs stringForColumn:@"id"];
            item.itemObject = [rs stringForColumn:@"json"];
            item.createdTime = [rs dateForColumn:@"createdTime"];
            // parse json string to object
            [jsonResult addObject:item];
            
        }
        [rs close];
    }];
    
    for (APKeyValueItem *item in jsonResult) {
        NSError * error;
        id object = [NSJSONSerialization JSONObjectWithData:[item.itemObject dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:(NSJSONReadingAllowFragments) error:&error];
        if (error) {
            NSLog(@"ERROR, faild to prase to json.");
            item.itemObject = nil;
        } else {
            item.itemObject = object;
        }
    }
    return jsonResult;
}

- (void)deleteObjectWithObjectById:(NSString *)objectId fromTable:(NSString *)tableName beforeDate:(NSDate *)date
{
    NSString *deleteId = nil;
    APKeyValueItem *item = [self getKeyValueItemById:objectId fromTable:tableName];
    if ([item.createdTime compare:date] == NSOrderedAscending) {
        deleteId = item.itemId;
    }
    
    if (deleteId != nil) {
        [self deleteObjectById:objectId fromTable:tableName];
    }
    
}

- (void)deleteObjectFromTable:(NSString *)tableName beforeDate:(NSDate *)date
{
    NSMutableArray<NSString *> *idList = [NSMutableArray new];
    NSArray<APKeyValueItem *> *itemList = [self getAllKeyValueItemFromTable:tableName];
    if (itemList != nil) {
        for (APKeyValueItem *item in itemList) {
            if ([item.createdTime compare:date] == NSOrderedAscending) {
                [idList addObject:item.itemId];
            }
        }
    }
    if (idList.count > 0) {
        [self deleteObjectsByIdArray:idList fromTable:tableName];
    }
}

@end
