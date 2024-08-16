//
//  SQPrint.m
//  sq
//
//  Created by Bimal Bhagrath on 2024-08-16.
//

#import <Foundation/Foundation.h>

#import "SQPrint.h"

@implementation SQPrint

+ (void)info:(NSString *)log context:(NSString *)context {
    printf("\033[1m%s\033[0m %s\n", [context ?: @"sq" UTF8String], log.UTF8String);
}

+ (void)success:(NSString *)log {
    printf("\033[1;92m\u2713\033[0;92m %s\033[0m\n", log.UTF8String);
}

+ (void)warning:(NSString *)log {
    printf("\033[1;93m!\033[0;93m %s\033[0m\n", log.UTF8String);
}

+ (void)error:(NSString *)log {
    printf("\033[1;91m\u2717\033[0;91m %s\033[0m\n", log.UTF8String);
}

+ (void)line:(NSString *)log {
    printf("%s\n", log.UTF8String);
}

@end
