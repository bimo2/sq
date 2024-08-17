//
//  SQREPL.m
//  sq
//
//  Created by Bimal Bhagrath on 2024-08-16.
//

#import <Foundation/Foundation.h>
#import "define.h"
#import "SQError.h"
#import "SQPrint.h"

#import "SQREPL.h"

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

- (void)cloneGitRepositoryWithURL:(NSString *)url error:(NSError **)error {
    NSURL *gitURL = [NSURL URLWithString:url];
    
    if (!gitURL || !gitURL.scheme || !gitURL.host) {
        *error = [NSError errorWithCode:SQGitError reason:@"invalid git url"];
        
        return;
    }
    
    NSFileManager *fileManager = NSFileManager.defaultManager;
    NSURL *pathURL = [fileManager.homeDirectoryForCurrentUser URLByAppendingPathComponent:gitURL.host];
    
    [fileManager createDirectoryAtURL:pathURL withIntermediateDirectories:YES attributes:nil error:error];
    [fileManager changeCurrentDirectoryPath:pathURL.path];
    
    NSInteger code = system([NSString stringWithFormat:@"git clone %@", url].UTF8String);
    
    if (code) {
        *error = [NSError errorWithCode:SQGitError reason:[NSString stringWithFormat:@"failed to clone: %@", url]];
        
        return;
    }
    
    [SQPrint line:[NSString stringWithFormat:@"cd ~/%@/%@", gitURL.host, gitURL.lastPathComponent.stringByDeletingPathExtension]];
}

- (void)writeDefaultSQFileWithFileManager:(NSFileManager *)fileManager error:(NSError **)error  {
    NSString *file = [fileManager.currentDirectoryPath stringByAppendingPathComponent:@SQ_FILE];
    NSString *contents = [NSString stringWithFormat:@SQ_DEFAULT, fileManager.currentDirectoryPath.lastPathComponent];
    
    [contents writeToFile:file atomically:YES encoding:NSUTF8StringEncoding error:error];
    [SQPrint line:[NSString stringWithFormat:@"%@ file created, learn more: %@", @SQ_FILE, @SQ_DOCS_URL]];
}

@end
