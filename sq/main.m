//
//  main.m
//  sq
//
//  Created by Bimal Bhagrath on 2024-08-16.
//

#import <Foundation/Foundation.h>
#import "define.h"
#import "SQError.h"
#import "SQPrint.h"

int find(char **url) {
    NSArray *extensions = @[ @SQ_FILE ];
    NSFileManager *manager = NSFileManager.defaultManager;
    NSString *path = manager.currentDirectoryPath;
    NSString *lastPath;
    NSError *error;
    BOOL isGitPath = NO;
    
    while (!isGitPath && ![path isEqualToString:lastPath]) {
        NSArray *directory = [manager contentsOfDirectoryAtPath:path error:&error];
        
        if (error) return SQPathError;
        
        for (NSString *file in directory) {
            if ([extensions containsObject:file]) {
                NSString *filePath = [path stringByAppendingPathComponent:file];
                
                *url = (char *) malloc((filePath.length + 1) * sizeof(char *));
                strcpy(*url, filePath.UTF8String);
                
                return 0;
            }
            
            isGitPath = isGitPath || [file isEqualToString:@".git"];
        }
        
        lastPath = path;
        path = [path stringByDeletingLastPathComponent];
    }
    
    return 0;
}

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        char *url = NULL;
        int code = find(&url);
        
        if (code) {
            [SQPrint error:[NSString stringWithFormat:@"(%d)", code]];
            free(url);
            
            return code;
        };
        
        NSString *path;
        
        if (url) {
            path = [NSString stringWithCString:url encoding:NSUTF8StringEncoding];
            free(url);
        }
        
        [SQPrint info:@"github/sq" context:nil];
        [SQPrint success:@"done"];
        [SQPrint warning:@"not found"];
        [SQPrint error:@"failed"];
        [SQPrint line:[NSString stringWithFormat:@"build %s%d", BUILD_VERSION, BUILD_NUMBER]];
    }
    
    return 0;
}
