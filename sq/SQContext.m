//
//  SQContext.m
//  sq
//
//  Created by Bimal Bhagrath on 2024-08-17.
//

#import <Foundation/Foundation.h>
#import "define.h"
#import "SQError.h"

#import "SQContext.h"

@implementation SQContext

- (instancetype)initWithData:(NSData *)data error:(NSError **)error {
    NSJSONReadingOptions options = NSJSONReadingJSON5Allowed | NSJSONReadingTopLevelDictionaryAssumed;
    id json = [NSJSONSerialization JSONObjectWithData:data options:options error:error];
    
    if (*error || ![json isKindOfClass:NSDictionary.class]) {
        *error = [NSError errorWithCode:SQSyntaxError reason:@"invalid JSON5 object"];
        
        return nil;
    }
    
    NSDictionary *object = json;
    id version = object[@"sq"];
    
    if (version && ![version isKindOfClass:NSNumber.class]) {
        *error = [NSError errorWithCode:SQSyntaxError reason:@"expected JSON5 number: sq"];
        
        return nil;
    }
    
    _version = [version integerValue] ?: SQ_SCHEMA;
    
    id repo = object[@"git"];
    
    if (repo && ![repo isKindOfClass:NSString.class]) {
        *error = [NSError errorWithCode:SQSyntaxError reason:@"expected JSON5 string: git"];
        
        return nil;
    }
    
    _repo = repo;
    
    id binaries = object[@"require"];
    
    if (!binaries) {
        _binaries = NSArray.array;
    } else if (![binaries isKindOfClass:NSArray.class]) {
        *error = [NSError errorWithCode:SQSyntaxError reason:@"expected JSON5 array: require"];
        
        return nil;
    } else {
        NSMutableArray *array = [NSMutableArray arrayWithArray:binaries];
        NSInteger index = 0;
        
        for (NSObject *item in array) {
            if (![item isKindOfClass:NSString.class]) {
                *error = [NSError errorWithCode:SQSyntaxError reason:[NSString stringWithFormat:@"expected JSON5 string: require[%ld]", index]];
                
                return nil;
            }
            
            index++;
        }
        
        _binaries = [NSArray arrayWithArray:array];
    }
    
    return self;
}

@end
