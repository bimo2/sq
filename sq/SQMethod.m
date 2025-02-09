//
//  SQMethod.m
//  sq
//
//  Created by Bimal Bhagrath on 2025-01-26.
//

#import <Foundation/Foundation.h>
#import "SQError.h"
#import "SQToken.h"

#import "SQMethod.h"

@implementation SQMethod

- (instancetype)initWithName:(NSString *)name info:(NSString *)info shell:(NSString *)shell commands:(NSArray *)commands {
  _name = name;
  _info = info;
  _shell = shell;
  _commands = commands.copy;

  return self;
}

- (NSString *)signature {
  NSString *result = [NSString stringWithString:self.name];
  SQTokenType filter = SQTokenTypeOption | SQTokenTypeXYZ;
  NSArray *tokens = [self _tokenizeWithFilter:filter];

  for (SQToken *token in tokens) {
    NSString *format;

    if ((token.type & SQTokenTypeXYZ) != 0) {
      format = @" ...";
    } else {
      format = token.isRequired ? @" <%@!>" : @" <%@>";
    }

    result = [result stringByAppendingFormat:format, token.name];
  }

  return result;
}

- (NSSet *)variables {
  NSMutableSet *map = NSMutableSet.set;
  NSArray *tokens = [self _tokenizeWithFilter:SQTokenTypeSecret];

  for (SQToken *token in tokens) [map addObject:token.name];

  return [NSSet setWithSet:map];
}

- (NSArray *)replaceWithOptions:(NSArray *)options secrets:(NSDictionary *)secrets error:(NSError **)error {
  NSMutableArray *lines = [NSMutableArray arrayWithArray:self.commands];
  SQTokenType filter = SQTokenTypeOption | SQTokenTypeXYZ;
  NSArray *tokens = [self _tokenizeWithFilter:filter];
  __block NSInteger index = 0;
  __block NSInteger seekIndex = 0;

  [tokens enumerateObjectsUsingBlock:^(SQToken *token, NSUInteger i, BOOL *stop) {
    if ((token.type & SQTokenTypeOption) != 0) {
      index++;
      seekIndex++;
    }

    if ((token.type & SQTokenTypeXYZ) != 0) {
      index = options.count > tokens.count ? options.count : tokens.count;
      *stop = YES;
    }
  }];

  filter = filter | SQTokenTypeSecret;
  tokens = [self _tokenizeWithFilter:filter];

  for (SQToken *token in tokens.reverseObjectEnumerator) {
    if ((token.type & SQTokenTypeNone) != 0) continue;

    if ((token.type & SQTokenTypeSecret) != 0) {
      NSString *string = [secrets valueForKey:token.name];

      if (!string) {
        NSString *reason = [NSString stringWithFormat:@"required: %@", token.name];

        *error = [NSError errorWithCode:SQRuntimeError reason:reason];

        return NSArray.array;
      }

      NSString *update = [lines[token.lineNumber] stringByReplacingCharactersInRange:token.range withString:string];

      [lines replaceObjectAtIndex:token.lineNumber withObject:update];

      continue;
    }

    if (--index < 0) break;

    if ((token.type & SQTokenTypeXYZ) != 0) {
      if (options.count > index) {
        NSMutableArray *array = NSMutableArray.array;

        do {
          NSString *option = [options objectAtIndex:index];

          [array addObject:option];
        } while (--index >= seekIndex);

        index++;

        NSString *group = [array.reverseObjectEnumerator.allObjects componentsJoinedByString:@" "];
        NSString *update = [lines[token.lineNumber] stringByReplacingCharactersInRange:token.range withString:group];

        [lines replaceObjectAtIndex:token.lineNumber withObject:update];

        continue;
      }

      NSString *update = [lines[token.lineNumber] stringByReplacingCharactersInRange:token.range withString:@""];

      [lines replaceObjectAtIndex:token.lineNumber withObject:update];

      continue;
    }

    NSString *option = options.count > index ? [options objectAtIndex:index] : @"-";

    if (![option isEqualToString:@"-"]) {
      NSString *string = [option containsString:@" "] ? [NSString stringWithFormat:@"\"%@\"", option] : option;
      NSString *update = [lines[token.lineNumber] stringByReplacingCharactersInRange:token.range withString:string];

      [lines replaceObjectAtIndex:token.lineNumber withObject:update];

      continue;
    }

    if (token.isRequired) {
      NSString *reason = [NSString stringWithFormat:@"required: %@", token.name];

      *error = [NSError errorWithCode:SQRuntimeError reason:reason];

      return NSArray.array;
    }

    if (token.defaultValue) {
      NSString *update = [lines[token.lineNumber] stringByReplacingCharactersInRange:token.range withString:token.defaultValue];

      [lines replaceObjectAtIndex:token.lineNumber withObject:update];

      continue;
    }

    NSString *update = [lines[token.lineNumber] stringByReplacingCharactersInRange:token.range withString:@""];

    [lines replaceObjectAtIndex:token.lineNumber withObject:update];
  }

  NSRegularExpression *regex1 = [NSRegularExpression regularExpressionWithPattern:@"(^\\s+|\\s+$)" options:NSRegularExpressionCaseInsensitive error:nil];
  NSRegularExpression *regex2 = [NSRegularExpression regularExpressionWithPattern:@"\\s\\s+(?=(?:[^\"]*(\")[^\"]*\\1)*[^\"]*$)" options:NSRegularExpressionCaseInsensitive error:nil];

  for (NSMutableString *line in lines) {
    [regex1 replaceMatchesInString:line options:0 range:NSMakeRange(0, line.length) withTemplate:@""];
    [regex2 replaceMatchesInString:line options:0 range:NSMakeRange(0, line.length) withTemplate:@" "];
  }

  return [NSArray arrayWithArray:lines];
}

- (NSArray *)_tokenizeWithFilter:(SQTokenType)filter {
  NSMutableArray *lines = [NSMutableArray arrayWithArray:self.commands];
  NSMutableArray *tokens = NSMutableArray.array;
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#(?<=#)((\\w+[!]?)|(\\w+ -> ([^\\s#]+|\"[^#]+\")))(?=#)#|###|%\\w+%" options:NSRegularExpressionCaseInsensitive error:nil];

  for (int i = 0; i < lines.count; i++) {
    NSString *line = [lines objectAtIndex:i];
    NSArray *matches = [regex matchesInString:line options:0 range:NSMakeRange(0, line.length)];

    for (NSTextCheckingResult *match in matches) {
      SQToken *token = [[SQToken alloc] initWithTextMatch:match line:line lineNumber:i];

      if ((filter & token.type) != 0) [tokens addObject:token];
    }
  }

  return [NSArray arrayWithArray:tokens];
}

@end
