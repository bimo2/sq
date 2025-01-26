//
//  SQContext.m
//  sq
//
//  Created by Bimal Bhagrath on 2025-01-26.
//

#import <Foundation/Foundation.h>
#import "define.h"
#import "SQError.h"

#import "SQContext.h"

@implementation SQContext

- (instancetype)initWithData:(NSData *)data error:(NSError *__autoreleasing *)error {
  id (^block)(NSError **, NSString *) = ^id(NSError **error, NSString *message) {
    *error = [NSError errorWithCode:SQSyntaxError reason:message];

    return nil;
  };

  NSJSONReadingOptions options = NSJSONReadingJSON5Allowed | NSJSONReadingTopLevelDictionaryAssumed;
  id json = [NSJSONSerialization JSONObjectWithData:data options:options error:error];

  if (*error || ![json isKindOfClass:NSDictionary.class]) return block(error, @"invalid JSON5 object");

  NSDictionary *object = json;
  id version = object[@"sq"];

  if (version && ![version isKindOfClass:NSNumber.class]) return block(error, @"expected JSON5 number: sq");

  _version = [version integerValue] ?: SQ_SCHEMA;

  id project = object[@"git"];

  if (project && ![project isKindOfClass:NSString.class]) return block(error, @"expected JSON5 string: git");

  _project = project;

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

  return self;
}

@end
