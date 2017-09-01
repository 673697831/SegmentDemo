//
//  APEncryptDBHelper.h
//  APSQLCipher
//
//  Created by ozr on 16/8/10.
//  Copyright © 2016年 ozr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APEncryptDBHelper : NSObject

/** encrypt sqlite database (same file) */
+ (BOOL)encryptDatabase:(NSString *)path encryptKey:(NSString *)encryptKey;

/** decrypt sqlite database (same file) */
+ (BOOL)unEncryptDatabase:(NSString *)path encryptKey:(NSString *)encryptKey;

/** encrypt sqlite database to new file */
+ (BOOL)encryptDatabase:(NSString *)sourcePath targetPath:(NSString *)targetPath encryptKey:(NSString *)encryptKey;

/** decrypt sqlite database to new file */
+ (BOOL)unEncryptDatabase:(NSString *)sourcePath targetPath:(NSString *)targetPath encryptKey:(NSString *)encryptKey;

/** change secretKey for sqlite database */
+ (BOOL)changeKey:(NSString *)dbPath originKey:(NSString *)originKey newKey:(NSString *)newKey;

@end
