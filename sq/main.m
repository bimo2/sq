//
//  main.m
//  sq
//
//  Created by Bimal Bhagrath on 2025-01-23.
//

#import <Foundation/Foundation.h>
#import "define.h"
#import "SQError.h"

int find(char **url) {
  NSFileManager *fileManager = NSFileManager.defaultManager;
  NSString *path = fileManager.currentDirectoryPath;
  NSString *lastPath;
  NSError *error;
  BOOL isGitPath = NO;

  while (!isGitPath && ![path isEqualToString:lastPath]) {
    NSArray *directory = [fileManager contentsOfDirectoryAtPath:path error:&error];

    if (error) return SQPathError;

    for (NSString *file in directory) {
      if ([file isEqualToString:@SQ_FILE]) {
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

int main(int argc, const char * argv[]) {
  @autoreleasepool {
    char *url = NULL;
    int code = find(&url);

    if (code) {
      free(url);

      return code;
    };

    if (url) {
      PRINT(url);
      free(url);
    }

    PRINT_SQ("objc");
    PRINT_INFO("install", "...");
    PRINT_TIME(0.0001);
    PRINT_ERROR("100");
  }

  return 0;
}
