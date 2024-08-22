//
//  SQError.h
//  sq
//
//  Created by Bimal Bhagrath on 2024-08-16.
//

#ifndef SQERROR_H
#define SQERROR_H

enum {
    SQObjCError = 100,
    SQPathError,
    SQGitError,
    SQSyntaxError,
    SQREPLError,
    SQSystemError,
    SQUserError,
};

@interface NSError (SQError)

+ (NSError *)errorWithCode:(NSInteger)code reason:(NSString *)reason;

@end

#endif // SQERROR_H
