//
//  APKeyValueItem.h
//  Pods
//
//  Created by ozr on 17/3/15.
//
//

#import <Foundation/Foundation.h>

@interface APKeyValueItem : NSObject

@property (strong, nonatomic) NSString *itemId;
@property (strong, nonatomic) id itemObject;
@property (strong, nonatomic) NSDate *createdTime;

@end
