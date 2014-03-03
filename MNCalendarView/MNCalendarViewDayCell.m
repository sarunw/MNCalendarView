//
//  MNCalendarViewDayCell.m
//  MNCalendarView
//
//  Created by Min Kim on 7/28/13.
//  Copyright (c) 2013 min. All rights reserved.
//

#import "MNCalendarViewDayCell.h"

NSString *const MNCalendarViewDayCellIdentifier = @"MNCalendarViewDayCellIdentifier";

@interface MNCalendarViewDayCell()

@property(nonatomic,strong,readwrite) NSDate *date;
@property(nonatomic,strong,readwrite) NSDate *month;
@property(nonatomic,assign,readwrite) NSUInteger weekday;

@end

@implementation MNCalendarViewDayCell

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    if ( self ) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    _textColor = UIColor.darkTextColor;
    _disableTextColor =  [UIColor colorWithRed:.85f green:.85f blue:.85f alpha:1.f];//UIColor.lightGrayColor;
    
    _textBackgroundColor = UIColor.whiteColor;
    _disableTextBackgroundColor = [UIColor colorWithRed:.96f green:.96f blue:.96f alpha:1.f];
}

- (void)setDisableTextColor:(UIColor *)disableTextColor
{
    NSLog(@"color %@", disableTextColor);
    _disableTextColor = disableTextColor;
}

- (void)setDate:(NSDate *)date
          month:(NSDate *)month
       calendar:(NSCalendar *)calendar {
  
  self.date     = date;
  self.month    = month;
  self.calendar = calendar;
  
  NSDateComponents *components =
  [self.calendar components:NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit
                   fromDate:self.date];
  
  NSDateComponents *monthComponents =
  [self.calendar components:NSMonthCalendarUnit
                   fromDate:self.month];
  
  self.weekday = components.weekday;
  self.titleLabel.text = [NSString stringWithFormat:@"%d", components.day];
    self.titleLabel.userInteractionEnabled = YES; // TODO: hack to work
    self.titleLabel.accessibilityLabel = [NSString stringWithFormat:@"%d/%d", components.day, components.month]; // TODO
  self.enabled = monthComponents.month == components.month;
  
  [self setNeedsDisplay];
}

- (void)setToday:(BOOL)today
{
    self.titleLabel.textColor = [UIColor redColor];
    self.backgroundColor = [UIColor whiteColor];
}

- (void)setEnabled:(BOOL)enabled {
  [super setEnabled:enabled];
  
        NSLog(@"inner color %@", self.disableTextColor);
    self.titleLabel.textColor = self.enabled ? self.textColor : self.disableTextColor;
//  self.enabled ? UIColor.darkTextColor : UIColor.lightGrayColor;
//  self.enabled ? UIColor.darkTextColor : [UIColor colorWithRed:230/255.0f green:231/255.0f blue:232/255.0f alpha:1];
//      self.enabled ? UIColor.darkTextColor :     [UIColor colorWithRed:.85f green:.85f blue:.85f alpha:1.f];
//      self.enabled ? UIColor.darkTextColor : [UIColor colorWithRed:202/255.0f green:202/255.0f blue:202/255.0f alpha:1];
//    self.enabled ? UIColor.darkTextColor : [UIColor colorWithRed:187/255.0f green:189/255.0f blue:192/255.0f alpha:1];


    
  
  self.backgroundColor =
    self.enabled ? self.textBackgroundColor : self.disableTextBackgroundColor;
}

- (void)drawRect:(CGRect)rect {
  [super drawRect:rect];
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGColorRef separatorColor = self.separatorColor.CGColor;
  
  CGSize size = self.bounds.size;
  
  if (self.weekday != 7) {
    CGFloat pixel = 1.f / [UIScreen mainScreen].scale;
    MNContextDrawLine(context,
                      CGPointMake(size.width - pixel, pixel),
                      CGPointMake(size.width - pixel, size.height),
                      separatorColor,
                      pixel);
  }
}

@end
