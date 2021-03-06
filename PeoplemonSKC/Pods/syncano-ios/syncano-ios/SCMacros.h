//
//  SCMacros.h
//  syncano4-ios
//
//  Created by Jan Lipmann on 27/03/15.
//  Copyright (c) 2015 Syncano. All rights reserved.
//


/*
 * Singleton for .h file
 */

#define SINGLETON_FOR_CLASS(classname) \
+ (classname *)shared##classname


/*
 * Singleton for .m file
 */

#define SINGLETON_IMPL_FOR_CLASS(classname) \
\
+ (classname *)shared##classname {                      \
\
static dispatch_once_t pred;                        \
__strong static classname * shared##classname = nil;\
dispatch_once( &pred, ^{                            \
shared##classname = [[self alloc] init]; });    \
return shared##classname;                           \
}

/**
 Raises an `NSInvalidArgumentException` if the `condition` does not pass.
 Use `description` to supply the way to fix the exception.
 */
#define SCParameterAssert(condition, description, ...) \
do {\
if (!(condition)) { \
[NSException raise:NSInvalidArgumentException \
format:description, ##__VA_ARGS__]; \
} \
} while(0)
