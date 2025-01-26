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

#import "SQDX.h"

@interface SQDX ()

@property (nonatomic, copy, readonly) NSString *path;
@property (nonatomic, copy, readonly) SQContext *context;

@end

@implementation SQDX

- (instancetype)initWithPath:(NSString *)path error:(NSError *__autoreleasing *)error {
  _path = path;

  if (self.path) {
    NSData *data = [NSData dataWithContentsOfFile:path];

    _context = [[SQContext alloc] initWithData:data error:error];
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

- (void)version {
  NSString *version = [NSString stringWithFormat:@"%s (%s)", VERSION, COMMIT_SHA];

  PRINT(version.UTF8String);
}

@end
