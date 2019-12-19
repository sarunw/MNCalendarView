//
//  MNCalendarView.h
//  MNCalendarView
//
//  Created by Min Kim on 7/23/13.
//  Copyright (c) 2013 min. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MN_MINUTE 60.f
#define MN_HOUR   MN_MINUTE * 60.f
#define MN_DAY    MN_HOUR * 24.f
#define MN_WEEK   MN_DAY * 7.f
#define MN_YEAR   MN_DAY * 365.f

typedef NS_ENUM(NSInteger, MNCalendarViewSelectingType) {
    MNCalendarViewSelectingTypeBeginDate,
    MNCalendarViewSelectingTypeEndDate
};

@protocol MNCalendarViewDelegate;

@interface MNCalendarView : UIView <UICollectionViewDataSource, UICollectionViewDelegate>

@property(nonatomic,strong,readonly) UICollectionView *collectionView;

@property(nonatomic,assign) id<MNCalendarViewDelegate> delegate;

@property(nonatomic,strong) NSCalendar *calendar;
@property(nonatomic,copy)   NSDate     *fromDate;
@property(nonatomic,copy)   NSDate     *toDate;

@property(nonatomic,copy)   NSDate     *beginDate;
@property(nonatomic,copy)   NSDate     *endDate;

@property(nonatomic,copy)   NSString   *accessibilityDomain;

/**
 This date format is applied for each date. Default is yyyy-MM-dd.
 */
@property(nonatomic,copy)   NSString   *dateFormat;
/**
 This date format is applied for each month. Default is yyyy-MM.
 */
@property(nonatomic,copy)   NSString   *monthFormat;

@property(nonatomic,strong) UIColor *separatorColor UI_APPEARANCE_SELECTOR; // default is the standard separator gray
@property(nonatomic, strong) UIColor *calendarBackgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *dateTextColor;
@property (nonatomic, strong) UIColor *dateBackgroundColor;
@property (nonatomic, strong) UIColor *disableDateTextColor;


@property(nonatomic,strong) Class headerViewClass;
@property(nonatomic,strong) Class weekdayCellClass;
@property(nonatomic,strong) Class dayCellClass;

- (void)reloadData;
- (void)registerUICollectionViewClasses; 
- (NSInteger)sectionForDate:(NSDate *)date;
- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated;

@end

@protocol MNCalendarViewDelegate <NSObject>

@optional

- (MNCalendarViewSelectingType)calendarViewCurrentSelection:(MNCalendarView *)calendarView;

- (BOOL)calendarView:(MNCalendarView *)calendarView dateAvailable:(NSDate *)date;
- (BOOL)calendarView:(MNCalendarView *)calendarView shouldSelectDate:(NSDate *)date;
- (void)calendarView:(MNCalendarView *)calendarView didSelectBeginDate:(NSDate *)date;
- (void)calendarView:(MNCalendarView *)calendarView didSelectEndDate:(NSDate *)date;

@end
