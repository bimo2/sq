//
//  SQToken.m
//  sq
//
//  Created by Bimal Bhagrath on 2025-01-26.
//

#import <Foundation/Foundation.h>

#import "SQToken.h"

@implementation SQToken

- (instancetype)initWithTextMatch:(NSTextCheckingResult *)textMatch line:(NSString *)line lineNumber:(NSInteger)lineNumber {
  NSRegularExpression *nameRegex = [NSRegularExpression regularExpressionWithPattern:@"\\w+[!]?" options:NSRegularExpressionCaseInsensitive error:nil];
  NSTextCheckingResult *nameMatch = [nameRegex firstMatchInString:line options:0 range:textMatch.range];
  NSString *name = [line substringWithRange:nameMatch.range];

  if ([name hasSuffix:@"!"]) {
    _name = [name substringToIndex:name.length - 1];
    _isRequired = YES;
    _defaultValue = nil;
  } else {
    _name = name;
    _isRequired = NO;

    NSRegularExpression *valueRegex = [NSRegularExpression regularExpressionWithPattern:@"(?<= -> )(.*?)(?=#)" options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *valueMatch = [valueRegex firstMatchInString:line options:0 range:textMatch.range];

    _defaultValue = valueMatch.range.length > 0 ? [line substringWithRange:valueMatch.range] : nil;
  }

  NSString *substring = [line substringWithRange:textMatch.range];

  if ([substring hasPrefix:@"%"] && [substring hasSuffix:@"%"]) {
    _type = SQTokenTypeSecret;
  } else if ([substring hasPrefix:@"#"] && [substring hasSuffix:@"#"]) {
    _type = SQTokenTypeOption;
  } else {
    _type = SQTokenTypeNone;
  }

  _lineNumber = lineNumber;
  _range = textMatch.range;

  return self;
}

@end
