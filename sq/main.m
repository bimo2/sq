//
//  main.m
//  sq
//
//  Created by Bimal Bhagrath on 2024-08-16.
//

#import <Foundation/Foundation.h>

#ifndef BUILD_NUMBER
#define BUILD_NUMBER 0
#endif

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"sq build #%d", BUILD_NUMBER);
    }

    return 0;
}
