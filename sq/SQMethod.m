//
//  SQMethod.m
//  sq
//
//  Created by Bimal Bhagrath on 2025-01-26.
//

#import <Foundation/Foundation.h>
#import "SQToken.h"

#import "SQMethod.h"

@implementation SQMethod

- (instancetype)initWithName:(NSString *)name info:(NSString *)info commands:(NSArray *)commands {
  _name = name;
  _info = info;
  _commands = commands.copy;

  return self;
}

- (NSString *)signature {
  NSString *result = [NSString stringWithString:self.name];
  NSArray *tokens = self._tokenize;

  for (SQToken *token in tokens) {
    NSString *format = token.isRequired ? @" <%@!>" : @" <%@>";

    result = [result stringByAppendingFormat:format, token.name];
  }

  return result;
}

- (NSArray *)_tokenize {
    NSMutableArray *lines = [NSMutableArray arrayWithArray:self.commands];
    NSMutableArray *tokens = NSMutableArray.array;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#(?<=#)((\\w+[!]?)|(\\w+ -> ([^\\s#]+|\"[^#]+\")))(?=#)#" options:NSRegularExpressionCaseInsensitive error:nil];

    for (int i = 0; i < lines.count; i++) {
        NSString *line = [lines objectAtIndex:i];
        NSArray *matches = [regex matchesInString:line options:0 range:NSMakeRange(0, line.length)];

        for (NSTextCheckingResult *match in matches) {
            SQToken *token = [[SQToken alloc] initWithTextMatch:match line:line lineNumber:i];

            [tokens addObject:token];
        }
    }

    return [NSArray arrayWithArray:tokens];
}

@end
