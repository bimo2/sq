//
//  SQError.m
//  sq
//
//  Created by Bimal Bhagrath on 2024-08-16.
//

#import <Foundation/Foundation.h>

#import "SQError.h"

@implementation NSError (SQError)

+ (NSError *)errorWithCode:(NSInteger)code reason:(NSString *)reason {
    NSDictionary *userInfo = @{
        NSLocalizedDescriptionKey: reason,
    };
    
    return [NSError errorWithDomain:@"com.github.sq" code:code userInfo:userInfo];
}

@end