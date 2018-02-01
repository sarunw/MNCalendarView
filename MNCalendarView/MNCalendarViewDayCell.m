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
@property(nonatomic,assign) BOOL isToday;

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

- (void)setDate:(NSDate *)date month:(NSDate *)month calendar:(NSCalendar *)calendar {
    
    self.date     = date;
    self.month    = month;
    self.calendar = calendar;
    
    NSDateComponents *components = [self.calendar components:NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit
                                                    fromDate:self.date];
    
    NSDateComponents *monthComponents = [self.calendar components:NSMonthCalendarUnit
                                                         fromDate:self.month];
    
    self.weekday = components.weekday;
    self.titleLabel.text = [NSString stringWithFormat:@"%d", components.day];
    self.titleLabel.userInteractionEnabled = YES; // TODO: hack to work
    self.titleLabel.accessibilityLabel = [NSString stringWithFormat:@"%d/%d", components.day, components.month]; // TODO
    self.enabled = monthComponents.month == components.month;
    
    [self setNeedsDisplay];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.titleLabel.highlightedTextColor = [UIColor whiteColor];
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        self.titleLabel.highlightedTextColor = [UIColor whiteColor];
    }
}

- (void)setToday:(BOOL)today {
    self.isToday = today;
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    self.titleLabel.textColor = self.enabled ? self.textColor : self.disableTextColor;
    self.backgroundColor = self.enabled ? self.textBackgroundColor : self.disableTextBackgroundColor;
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
    
    if (self.selected || self.isToday || self.highlighted) {
        self.titleLabel.highlightedTextColor = [UIColor whiteColor];
        [self.selected ? self.selectedBackgroundColor : self.disableTextColor setStroke];
        if (self.selected || self.highlighted) {
            CGContextSetRGBFillColor(context, 211/255.0f, 14/255.0f, 55/255.0f, self.selected ? 1 : 0.5);
            CGContextSetRGBStrokeColor(context, 211/255.0f, 14/255.0f, 55/255.0f, self.selected ? 1 : 0.5);
            CGContextFillEllipseInRect (context, [self circleFrame]);
            CGContextFillPath(context);
        }
        if (self.isToday) {
            CGContextSetLineWidth(context, 2);
            CGContextStrokeEllipseInRect(context, [self circleFrame]);
        }
        
    }
}

- (CGRect)circleFrame {
    CGRect rect = self.bounds;
    return CGRectInset(rect, 5, 5);
}

@end
