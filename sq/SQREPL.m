//
//  SQREPL.m
//  sq
//
//  Created by Bimal Bhagrath on 2024-08-16.
//

#import <Foundation/Foundation.h>
#import "define.h"
#import "SQPrint.h"

#import "SQREPL.h"

@implementation SQREPL

- (instancetype)initWitPath:(NSString *)path {
    return self;
}

- (void)version {
#if TARGET_CPU_ARM64
    NSString *arch = @"apple";
#else
    NSString *arch = @"intel";
#endif
    
    [SQPrint line:[NSString stringWithFormat:@"sq.%@ %s (%s%d)", arch, VERSION, BUILD_VERSION, BUILD_NUMBER]];
}

@end