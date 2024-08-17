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
    
    if (*error) return nil;
    
    if (![json isKindOfClass:NSDictionary.class]) {
        *error = [NSError errorWithCode:SQSyntaxError reason:@"expected JSON5 object"];
        
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
    
    _repo = repo ?: @"";
    
    return self;
}

@end
