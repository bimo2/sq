//
//  SQREPL.h
//  sq
//
//  Created by Bimal Bhagrath on 2024-08-16.
//

#ifndef SQREPL_H
#define SQREPL_H

@interface SQREPL : NSObject

@property (nonatomic, copy) NSString *path;

- (instancetype)initWitPath:(NSString *)path;

- (void)docs;

- (void)version;

- (void)writeDefaultSQFileWithFileManager:(NSFileManager *)fileManager error:(NSError **)error ;

@end

#endif // SQREPL_H
