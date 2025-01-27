//
//  SQDX.m
//  sq
//
//  Created by Bimal Bhagrath on 2025-01-23.
//

#import <Foundation/Foundation.h>
#import "define.h"
#import "SQContext.h"
#import "SQError.h"
#import "SQMethod.h"

#import "SQDX.h"

@interface SQDX ()

@property (nonatomic, copy, readonly) NSString *path;
@property (nonatomic, copy, readonly) SQContext *context;

@end

@implementation SQDX

- (instancetype)initWithPath:(NSString *)path error:(NSError *__autoreleasing *)error {
  _path = path;

  if (self.path) {
    NSData *fileData = [NSData dataWithContentsOfFile:path];

    _context = [[SQContext alloc] initWithFileData:fileData error:error];
  }

  return self;
}

- (void)json5WithFileManager:(NSFileManager *)fileManager error:(NSError *__autoreleasing *)error {
  if (self.path) return;

  NSString *file = [fileManager.currentDirectoryPath stringByAppendingPathComponent:@SQ_FILE];
  NSString *contents = [NSString stringWithFormat:@SQ_JSON5, fileManager.currentDirectoryPath.lastPathComponent];
  NSString *hint = [NSString stringWithFormat:@"learn more: %@", @SQ_GITHUB_URL];

  [contents writeToFile:file atomically:YES encoding:NSUTF8StringEncoding error:error];
  PRINT_SQ("file created.");
  PRINT(ASCII_JSON5);
  PRINT(hint.UTF8String);
}

- (void)docs {
  if (!self.context) return;

  NSString *project = self.context.project ?: self.path.stringByDeletingLastPathComponent.lastPathComponent;
  NSString *header = [NSString stringWithFormat:@"(%@)\n-", project];

  PRINT_SQ(header.UTF8String);

  NSInteger maxLength = 0;
  NSInteger index = 1;

  for (SQMethod *method in self.context.methods) {
    NSString *signature = method.signature;

    if (signature.length > maxLength) maxLength = signature.length;
  }

  NSArray *sorted = [self.context.methods sortedArrayUsingComparator:^NSComparisonResult(SQMethod *a, SQMethod *b) {
    return [a.name compare:b.name];
  }];

  for (SQMethod *method in sorted) {
    NSString *leading = [method.signature stringByPaddingToLength:maxLength + 4 withString:@" " startingAtIndex:0];
    NSString *line = [leading stringByAppendingString:method.info ?: @""];

    PRINT(line.UTF8String);
    index++;
  }
}

- (void)version {
  NSString *version = [NSString stringWithFormat:@"%s (%s)", VERSION, COMMIT_SHA];

  PRINT(version.UTF8String);
}

@end
