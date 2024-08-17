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

@interface SQREPL ()

@property (nonatomic, copy) NSString *path;

@end

@implementation SQREPL

- (instancetype)initWitPath:(NSString *)path {
    _path = path;
    
    return self;
}

- (void)docs {
    [SQPrint info:[NSString stringWithFormat:@"%@\n-", nil] context:nil];
    [SQPrint line:@"<url>            clone git repository"];
    [SQPrint line:@"init             create .sq file"];
    [SQPrint line:@"--version, -v"];
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
