//
//  SQError.h
//  sq
//
//  Created by Bimal Bhagrath on 2025-01-23.
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
