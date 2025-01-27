//
//  main.m
//  sq
//
//  Created by Bimal Bhagrath on 2025-01-23.
//

#import <Foundation/Foundation.h>
#import "define.h"
#import "SQDX.h"
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
    path = path.stringByDeletingLastPathComponent;
  }

  return 0;
}

int fail(int code, const char *description) {
  if (description) {
    PRINT_ERROR(description);
  } else {
    NSString *string = [NSString stringWithFormat:@"(%d)", code];

    PRINT_ERROR(string.UTF8String);
  }

  return code;
}

int main(int argc, const char * argv[]) {
  @autoreleasepool {
    char *url = NULL;
    int code = find(&url);

    if (code) {
      free(url);

      return fail(code, NULL);
    };

    NSString *path;
    NSError *error;

    if (url) {
      path = [NSString stringWithCString:url encoding:NSUTF8StringEncoding];
      free(url);
    }

    SQDX *app = [[SQDX alloc] initWithPath:path error:&error];

    if (error) return fail((int)error.code, error.localizedDescription.UTF8String);
    if (!app) return fail(SQCError, NULL);

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

    if ([command isEqualToString:@"."]) {
      [app json5WithFileManager:NSFileManager.defaultManager error:&error];
    } else if ([command isEqualToString:@"--version"] || [command isEqualToString:@"-v"]) {
      [app version];
    } else {
      [app executeWithName:command options:options error:&error];
    }

    if (error) return fail((int)error.code, error.localizedDescription.UTF8String);
  }

  return 0;
}
