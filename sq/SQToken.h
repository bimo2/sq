//
//  SQToken.h
//  sq
//
//  Created by Bimal Bhagrath on 2024-08-20.
//

#ifndef SQTOKEN_H
#define SQTOKEN_H

typedef NS_OPTIONS(NSUInteger, SQTokenType) {
    SQTokenTypeNone = 0,
    SQTokenTypeOption = 1 << 0,
    SQTokenTypeSecret = 1 << 1,
};

@interface SQToken : NSObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, readonly) BOOL isRequired;
@property (nonatomic, readonly) SQTokenType type;
@property (nonatomic, copy, readonly) NSString *defaultValue;
@property (nonatomic, readonly) NSInteger lineNumber;
@property (nonatomic, readonly) NSRange range;

- (instancetype)initWithTextMatch:(NSTextCheckingResult *)textMatch line:(NSString *)line lineNumber:(NSInteger)lineNumber;

@end

#endif // SQTOKEN_H
