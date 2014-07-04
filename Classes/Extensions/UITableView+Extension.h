//
//  UITableView+Extension.h
//  GrokTalk
//
//  Created by Kristian Delay on 4/8/14.
//  Copyright (c) 2014 MilliCorp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UITableView (Extensions)

- (void) reloadSection:(NSInteger)section withRowAnimation:(UITableViewRowAnimation)rowAnimation;

@end
