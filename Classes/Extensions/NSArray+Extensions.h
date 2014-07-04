//
//  NSArray+Extensions.h
//  FinalPhoneUniv
//
//  Created by David Artman on 8/31/12.
//  Copyright (c) 2012 Millicorp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Extensions)

-(NSArray *)arrayByRemovingObject:(id)anObject;
-(NSArray *)arrayByRemovingObjectsFromArray:(NSArray *)otherArray;

-(NSArray *)arrayByReversingOrder;

+(NSArray *)arrayWithNilTerminatingArguments:(va_list)arguments startingWithObject:(id)firstObject;

-(NSArray *)objectsSharedWithArray:(NSArray *)otherArray;

-(NSArray *)arrayByAddingObject:(id)object numberOfTimes:(NSInteger)numberOfTimes;

-(id)randomObject;

@end
