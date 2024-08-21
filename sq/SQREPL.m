//
//  SQREPL.m
//  sq
//
//  Created by Bimal Bhagrath on 2024-08-16.
//

#import <Foundation/Foundation.h>
#import "define.h"
#import "SQContext.h"
#import "SQError.h"
#import "SQScript.h"

#import "SQREPL.h"

@interface SQREPL ()

@property (nonatomic) SQContext *context;

@end

@implementation SQREPL

- (instancetype)initWitPath:(NSString *)path error:(NSError **)error {
    _path = path;
    
    if (path) _context = [[SQContext alloc] initWithData:[NSData dataWithContentsOfFile:path] error:error];
    
    return self;
}

- (void)docs {
    NSString *header = [NSString stringWithFormat:@"(%@)\n-", self.context.project ?: @"null"];
    
    PRINT_HEADER(header.UTF8String);
    
    if (self.context) {
        NSInteger maxLength = 0;
        NSInteger index = 1;
        
        for (SQScript *script in self.context.scripts) {
            NSString *signature = script.signature;
            
            if (signature.length > maxLength) maxLength = signature.length;
        }
        
        NSArray *sorted = [self.context.scripts sortedArrayUsingComparator:^NSComparisonResult(SQScript *a, SQScript *b) {
            return [a.name compare:b.name];
        }];
        
        for (SQScript *script in sorted) {
            NSString *leading = [script.signature stringByPaddingToLength:maxLength + 4 withString:@" " startingAtIndex:0];
            NSString *line = [leading stringByAppendingString:script.info ?: @""];
            
            PRINT(line.UTF8String);
            index++;
        }
        
        NSArray *errors = self.resolve;
        
        if (errors.count) {
            for (NSError *error in errors) PRINT_ERROR(error.localizedDescription.UTF8String);
        }
    } else {
        PRINT(@"<url>            clone git repository".UTF8String);
        PRINT(@".                create .sq file".UTF8String);
        PRINT(@"--version, -v".UTF8String);
    }
}

- (void)version {
#if TARGET_CPU_ARM64
    NSString *arch = @"apple";
#else
    NSString *arch = @"intel";
#endif
    
    NSString *string = [NSString stringWithFormat:@"%@ %s (%s%d)", arch, VERSION, BUILD_VERSION, BUILD_NUMBER];
    
    PRINT(string.UTF8String);
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
    
    NSString *command = [NSString stringWithFormat:@"cd ~/%@/%@", gitURL.host, gitURL.lastPathComponent.stringByDeletingPathExtension];
    
    PRINT_COMMAND(command.UTF8String);
}

- (void)writeDefaultSQFileWithFileManager:(NSFileManager *)fileManager error:(NSError **)error {
    NSString *project = fileManager.currentDirectoryPath.lastPathComponent;
    NSString *file = [fileManager.currentDirectoryPath stringByAppendingPathComponent:@SQ_FILE];
    NSString *contents = [NSString stringWithFormat:@SQ_DEFAULT, fileManager.currentDirectoryPath.lastPathComponent];
    NSString *caption = [NSString stringWithFormat:@"learn more: %@", @SQ_DOCS_URL];
    
    [contents writeToFile:file atomically:YES encoding:NSUTF8StringEncoding error:error];
    PRINT_HEADER(project.UTF8String);
    PRINT_FILE;
    PRINT(caption.UTF8String);
}

- (void)evaluateWithName:(NSString *)name options:(NSArray *)options error:(NSError **)error {
    if (!self.context) {
        *error = [NSError errorWithCode:SQREPLError reason:[NSString stringWithFormat:@"not found: %@", @SQ_FILE]];
        
        return;
    }
    
    SQScript *script;
    
    for (SQScript *object in self.context.scripts) {
        if ([object.name isEqualToString:name]) {
            script = object;
            
            break;
        }
    }
    
    if (!script) {
        *error = [NSError errorWithCode:SQREPLError reason:[NSString stringWithFormat:@"undefined: %@", name]];
        
        return;
    }
    
    NSDate *start = NSDate.date;
    NSArray *lines = [script replaceWithOptions:options error:error];
    
    if (*error) return;
    
    for (NSString *line in lines) {
        PRINT_INFO(name.UTF8String, line.UTF8String);
        
        NSInteger code = system([NSString stringWithFormat:@"cd %@ && %@ -c '%@'", self.path.stringByDeletingLastPathComponent, script.shell, line].UTF8String);
        
        if (code) {
            *error = [NSError errorWithCode:code reason:[NSString stringWithFormat:@"failed (%li)", code]];
            
            return;
        }
    }
    
    NSNumber *elapsed = [NSNumber numberWithDouble:start.timeIntervalSinceNow * -1];
    
    PRINT_TIME(elapsed.doubleValue);
}

- (NSArray *)resolve {
    if (!self.context) return nil;
    
    NSMutableArray *errors = NSMutableArray.array;
    
    for (NSString *bin in self.context.binaries) {
        NSInteger status;
        
        if (bin.isAbsolutePath) {
            status = ![NSFileManager.defaultManager fileExistsAtPath:bin];
        } else {
            NSString *command = [NSString stringWithFormat:@"sh -c 'which -s %@'", bin];
            
            status = system(command.UTF8String);
        }
        
        if (status) {
            NSError *error = [NSError errorWithCode:SQSystemError reason:[NSString stringWithFormat:@"%@ not found", bin]];
            
            [errors addObject:error];
        }
    }
    
    return [NSArray arrayWithArray:errors];
}

@end
