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
#import "SQREPL.h"

#ifdef TESTING
#import "testing.h"
#endif

int fail(int code) {
    [SQPrint error:[NSString stringWithFormat:@"(%d)", code]];
    
    return code;
}

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
            free(url);
            
            return fail(code);
        };
        
        NSString *path;
        
        if (url) {
            path = [NSString stringWithCString:url encoding:NSUTF8StringEncoding];
            free(url);
        }
        
        SQREPL *app = [[SQREPL alloc] initWitPath:path];
        
        if (!app) return fail(SQObjCError);

        if (argc < 2) {
            [app docs];

            return 0;
        }
        
        NSString *command = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
        NSMutableArray *options = NSMutableArray.array;
        
        for (int i = 2; i < argc; i++) {
            NSString *value = [NSString stringWithCString:argv[i] encoding:NSUTF8StringEncoding];
            
            [options addObject:value];
        }
        
        if ([command isEqualToString:@"--version"] || [command isEqualToString:@"-v"]) [app version];
    }
    
    return 0;
}
