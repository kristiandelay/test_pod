//
//  UITableView+Extension.m
//  GrokTalk
//
//  Created by Kristian Delay on 4/8/14.
//  Copyright (c) 2014 MilliCorp. All rights reserved.
//

#import "UITableView+Extension.h"

@implementation UITableView (Extensions)

- (void) reloadSection:(NSInteger)section withRowAnimation:(UITableViewRowAnimation)rowAnimation
{
    NSRange range = NSMakeRange(section, 1);
    NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
    [self reloadSections:sectionToReload withRowAnimation:rowAnimation];
}

@end
