//
//  SQPrint.h
//  sq
//
//  Created by Bimal Bhagrath on 2024-08-16.
//

#ifndef SQPRINT_H
#define SQPRINT_H

@interface SQPrint : NSObject

+ (void)info:(NSString *)log context:(NSString *)context;

+ (void)success:(NSString *)log;

+ (void)warning:(NSString *)log;

+ (void)error:(NSString *)log;

+ (void)line:(NSString *)log;

@end

#endif // SQPRINT_H
