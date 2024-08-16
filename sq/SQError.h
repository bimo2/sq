//
//  SQError.h
//  sq
//
//  Created by Bimal Bhagrath on 2024-08-16.
//

#ifndef SQERROR_H
#define SQERROR_H

enum {
    SQPathError = 100,
};

@interface NSError (SQError)

+ (NSError *)errorWithCode:(NSInteger)code reason:(NSString *)reason;

@end

#endif // SQERROR_H
