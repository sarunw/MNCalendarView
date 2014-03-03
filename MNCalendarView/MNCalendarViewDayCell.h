//
//  MNCalendarViewDayCell.h
//  MNCalendarView
//
//  Created by Min Kim on 7/28/13.
//  Copyright (c) 2013 min. All rights reserved.
//

#import "MNCalendarViewCell.h"

extern NSString *const MNCalendarViewDayCellIdentifier;

@interface MNCalendarViewDayCell : MNCalendarViewCell

@property(nonatomic,strong,readonly) NSDate *date;
@property(nonatomic,strong,readonly) NSDate *month;

@property (nonatomic, strong) UIColor *textColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *textBackgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *disableTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *disableTextBackgroundColor UI_APPEARANCE_SELECTOR;

- (void)setDate:(NSDate *)date
          month:(NSDate *)month
       calendar:(NSCalendar *)calendar;

@end
