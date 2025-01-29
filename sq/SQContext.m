//
//  SQContext.m
//  sq
//
//  Created by Bimal Bhagrath on 2025-01-26.
//

#import <Foundation/Foundation.h>
#import "define.h"
#import "SQError.h"
#import "SQMethod.h"

#import "SQContext.h"

@implementation SQContext

- (instancetype)initWithFileData:(NSData *)fileData error:(NSError *__autoreleasing *)error {
  id (^block)(NSError **, NSString *) = ^id(NSError **error, NSString *reason) {
    *error = [NSError errorWithCode:SQSyntaxError reason:reason];

    return nil;
  };

  NSJSONReadingOptions options = NSJSONReadingJSON5Allowed | NSJSONReadingTopLevelDictionaryAssumed;
  id json = [NSJSONSerialization JSONObjectWithData:fileData options:options error:error];

  if (*error || ![json isKindOfClass:NSDictionary.class]) return block(error, @"invalid JSON5 object");

  NSDictionary *object = json;
  id version = object[@"sq"];

  if (version && ![version isKindOfClass:NSNumber.class]) return block(error, @"expected JSON5 number: sq");

  _version = [version integerValue] ?: SQ_SCHEMA;

  id project = object[@"git"];

  if (project && ![project isKindOfClass:NSString.class]) return block(error, @"expected JSON5 string: git");

  _project = project;

  id env = object[@"env"];

  if (env && ![env isKindOfClass:NSString.class]) return block(error, @"expected JSON5 string: env");

  _env = env ?: @DEFAULT_ENV;

  id binaries = object[@"require"];

  if (!binaries) {
    _binaries = NSArray.array;
  } else if (![binaries isKindOfClass:NSArray.class]) {
    return block(error, @"expected JSON5 array: require");
  } else {
    NSMutableArray *array = [NSMutableArray arrayWithArray:binaries];
    NSInteger index = 0;

    for (NSObject *item in array) {
      if (![item isKindOfClass:NSString.class]) {
        NSString *message = [NSString stringWithFormat:@"expected JSON5 string: require[%ld]", index];

        return block(error, message);
      }

      index++;
    }

    _binaries = [NSArray arrayWithArray:array];
  }

  id methods = object[@"bin"];

  if (!methods) {
    _methods = NSArray.array;
  } else if (![methods isKindOfClass:NSDictionary.class]) {
    return block(error, @"expected JSON5 object: bin");
  } else {
    NSDictionary *map = [NSMutableDictionary dictionaryWithDictionary:methods];
    NSMutableArray *array = NSMutableArray.array;
    NSArray *shells = @[ @"sh", @"bash", @"zsh", @"csh", @"ksh" ];

    for (NSString *key in map.allKeys) {
      if (![map[key] isKindOfClass:NSDictionary.class]) {
        NSString *message = [NSString stringWithFormat:@"expected JSON5 object: bin.%@", key];

        return block(error, message);
      }

      id info = map[key][@"d"];

      if (info && ![info isKindOfClass:NSString.class]) {
        NSString *message = [NSString stringWithFormat:@"expected JSON5 string: bin.%@.d", key];

        return block(error, message);
      }

      NSString *shell;

      for (NSString *item in shells) {
        if (map[key][item]) {
          shell = item;

          break;
        }
      }

      if (!shell) {
        SQMethod *method = [[SQMethod alloc] initWithName:key info:info shell:@DEFAULT_SH commands:NSArray.array];

        [array addObject:method];

        continue;
      }

      id commands = map[key][shell];

      if ([commands isKindOfClass:NSString.class]) {
        SQMethod *method = [[SQMethod alloc] initWithName:key info:info shell:shell commands:@[ commands ]];

        [array addObject:method];

        continue;
      }

      if ([commands isKindOfClass:NSArray.class]) {
        NSInteger index = 0;

        for (NSObject *item in commands) {
          if (![item isKindOfClass:NSString.class]) {
            NSString *message = [NSString stringWithFormat:@"expected JSON5 string: bin.%@.%@[%ld]", key, shell, index];

            return block(error, message);
          }

          index++;
        }

        SQMethod *method = [[SQMethod alloc] initWithName:key info:info shell:shell commands:commands];

        [array addObject:method];

        continue;
      }

      NSString *message = [NSString stringWithFormat:@"expected JSON5 string|array: bin.%@.%@", key, shell];

      return block(error, message);
    }

    _methods = [NSArray arrayWithArray:array];
  }

  return self;
}

@end
