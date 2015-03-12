//
//  MNCalendarViewCell.h
//  MNCalendarView
//
//  Created by Min Kim on 7/26/13.
//  Copyright (c) 2013 min. All rights reserved.
//

#import <UIKit/UIKit.h>

CG_EXTERN void MNContextDrawLine(CGContextRef c, CGPoint start, CGPoint end, CGColorRef color, CGFloat lineWidth);

@interface MNCalendarViewCell : UICollectionViewCell

@property(nonatomic,strong) NSCalendar *calendar;

@property(nonatomic,assign,getter = isEnabled) BOOL enabled;

@property(nonatomic,strong) UIColor *separatorColor;
@property(nonatomic,strong) UIColor *selectedBackgroundColor UI_APPEARANCE_SELECTOR;

@property(nonatomic,strong,readonly) UILabel *titleLabel;
@property (nonatomic, strong) UIFont *titleFont UI_APPEARANCE_SELECTOR;

@end
