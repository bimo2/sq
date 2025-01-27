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
@property (nonatomic, readonly) NSDictionary *secrets;

@end

@implementation SQDX

- (instancetype)initWithPath:(NSString *)path error:(NSError *__autoreleasing *)error {
  _path = path;

  if (self.path) {
    NSData *fileData = [NSData dataWithContentsOfFile:self.path];

    _context = [[SQContext alloc] initWithFileData:fileData error:error];

    if (*error) return nil;

    NSString *envPath = [path.stringByDeletingLastPathComponent stringByAppendingPathComponent:self.context.env];
    NSMutableDictionary *secrets = NSMutableDictionary.dictionary;

    if ([NSFileManager.defaultManager fileExistsAtPath:envPath]) {
      NSString *contents = [NSString stringWithContentsOfFile:envPath encoding:NSUTF8StringEncoding error:error];

      if (contents) {
        NSArray *lines = [contents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

        for (NSString *line in lines) {
          if ([line hasPrefix:@"#"]) continue;

          NSArray *components = [line componentsSeparatedByString:@"="];

          if (components.count == 2) {
            NSString *key = [components.firstObject stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
            NSString *value = [components.lastObject stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];

            secrets[key] = value;
          }
        }
      }
    }

    _secrets = [NSDictionary dictionaryWithDictionary:secrets];
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

- (void)executeWithName:(NSString *)name options:(NSArray *)options error:(NSError **)error {
  if (!self.context) {
    NSString *reason = [NSString stringWithFormat:@"not found: %@", @SQ_FILE];

    *error = [NSError errorWithCode:SQPathError reason:reason];

    return;
  }

  SQMethod *method;

  for (SQMethod *object in self.context.methods) {
    if ([object.name isEqualToString:name]) {
      method = object;

      break;
    }
  }

  if (!method) {
    NSString *reason = [NSString stringWithFormat:@"undefined: %@", name];

    *error = [NSError errorWithCode:SQRuntimeError reason:reason];

    return;
  }

  NSDate *start = NSDate.date;
  NSArray *lines = [method replaceWithOptions:options error:error];

  if (*error) return;

  for (NSString *line in lines) {
    PRINT_INFO(name.UTF8String, line.UTF8String);

    NSString *command = [NSString stringWithFormat:@"cd %@ && zsh -c '%@'", self.path.stringByDeletingLastPathComponent, line];
    NSInteger code = system(command.UTF8String);

    if (code) {
      NSString *reason = [NSString stringWithFormat:@"failed: %li", code];

      *error = [NSError errorWithCode:code reason:reason];

      return;
    }
  }

  NSNumber *elapsed = [NSNumber numberWithDouble:start.timeIntervalSinceNow * -1];

  PRINT_TIME(elapsed.doubleValue);
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

  NSArray *errors = self._resolve;

  for (NSError *error in errors) PRINT_ERROR(error.localizedDescription.UTF8String);
}

- (void)version {
  NSString *sha = [@COMMIT_SHA substringToIndex:7];
  NSString *version = [NSString stringWithFormat:@"%s (%@)", VERSION, sha];

  PRINT(version.UTF8String);
}

- (NSArray *)_resolve {
  if (!self.context) return nil;

  NSMutableArray *errors = NSMutableArray.array;

  for (NSString *bin in self.context.binaries) {
    NSInteger status;

    if (bin.isAbsolutePath) {
      status = ![NSFileManager.defaultManager fileExistsAtPath:bin];
    } else {
      NSString *command = [NSString stringWithFormat:@"zsh -c 'which -s %@' > /dev/null 2>&1", bin];

      status = system(command.UTF8String);
    }

    if (status) {
      NSString *reason = [NSString stringWithFormat:@"%@ not found", bin];
      NSError *error = [NSError errorWithCode:SQSystemError reason:reason];

      [errors addObject:error];
    }
  }

  return [NSArray arrayWithArray:errors];
}

@end
