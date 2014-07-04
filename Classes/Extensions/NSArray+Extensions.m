//
//  NSArray+Extensions.m
//  FinalPhoneUniv
//
//  Created by David Artman on 8/31/12.
//  Copyright (c) 2012 Millicorp. All rights reserved.
//

#import "NSArray+Extensions.h"

@implementation NSArray (Extensions)

-(NSArray *)arrayByRemovingObject:(id)anObject
{
    NSArray *returnValue = self;
    if(anObject)
    {
        NSInteger indexOfObject = [self indexOfObject:anObject];
        if(indexOfObject != NSNotFound)
        {
            NSArray *firstArray = nil;
            NSArray *secondArray = nil;
            if(indexOfObject > 0)
            {
                firstArray = [self subarrayWithRange:NSMakeRange(0, indexOfObject)];
            }
            if(indexOfObject < self.count - 1)
            {
                secondArray = [self subarrayWithRange:NSMakeRange(indexOfObject + 1, self.count - indexOfObject - 1)];
            }
            
            if(firstArray)
            {
                returnValue = firstArray;
            }
            else
            {
                returnValue = [NSArray array];
            }
            if(secondArray)
            {
                returnValue = [returnValue arrayByAddingObjectsFromArray:secondArray];
            }
        }
    }
    return returnValue;
}

-(NSArray *)arrayByRemovingObjectsFromArray:(NSArray *)otherArray
{
    NSArray *returnValue = self;
    if(otherArray)
    {
        for(id currentObject in otherArray)
        {
            returnValue = [returnValue arrayByRemovingObject:currentObject];
        }
    }
    return returnValue;
}

-(NSArray *)arrayByReversingOrder
{
    return [[self reverseObjectEnumerator] allObjects];
}

+(NSArray *)arrayWithNilTerminatingArguments:(va_list)arguments startingWithObject:(id)firstObject
{
    NSMutableArray *returnValue = [NSMutableArray array];
    for(id currentArgument = firstObject; currentArgument != nil; currentArgument = va_arg(arguments, id))
    {
        [returnValue addObject:currentArgument];
    }
    return [NSArray arrayWithArray:returnValue];
}

-(NSArray *)objectsSharedWithArray:(NSArray *)otherArray
{
    NSMutableArray *returnValue = [NSMutableArray array];
    for(id currentObject in otherArray)
    {
        if([self containsObject:currentObject])
        {
            [returnValue addObject:currentObject];
        }
    }
    return returnValue;
}

-(NSArray *)arrayByAddingObject:(id)object numberOfTimes:(NSInteger)numberOfTimes
{
    NSMutableArray *objectsToAdd = [NSMutableArray arrayWithCapacity:numberOfTimes];
    for(NSInteger numberOfTimesAdded = 0; numberOfTimesAdded < numberOfTimes; numberOfTimesAdded++)
    {
        [objectsToAdd addObject:object];
    }
    return [self arrayByAddingObjectsFromArray:objectsToAdd];
}

-(id)randomObject
{
    if(self.count > 0)
    {
        return [self objectAtIndex:arc4random() % [self count]];
    }
    else
    {
        return nil;
    }
}

@end
