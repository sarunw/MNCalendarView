//
//  MNCalendarView.m
//  MNCalendarView
//
//  Created by Min Kim on 7/23/13.
//  Copyright (c) 2013 min. All rights reserved.
//

#import "MNCalendarView.h"
#import "MNCalendarViewLayout.h"
#import "MNCalendarViewDayCell.h"
#import "MNCalendarViewWeekdayCell.h"
#import "MNCalendarHeaderView.h"
#import "MNFastDateEnumeration.h"
#import "NSDate+MNAdditions.h"

@interface MNCalendarView() <UICollectionViewDataSource, UICollectionViewDelegate>

@property(nonatomic,strong,readwrite) UICollectionView *collectionView;
@property(nonatomic,strong,readwrite) UICollectionViewFlowLayout *layout;

@property(nonatomic,strong,readwrite) NSArray *monthDates;
@property(nonatomic,strong,readwrite) NSArray *weekdaySymbols;
@property(nonatomic,assign,readwrite) NSUInteger daysInWeek;

@property(nonatomic,strong,readwrite) NSDateFormatter *monthFormatter;
@property(nonatomic,strong) NSDateFormatter *accessibilityDateFormatter;

- (NSDate *)firstVisibleDateOfMonth:(NSDate *)date;
- (NSDate *)lastVisibleDateOfMonth:(NSDate *)date;

- (BOOL)dateEnabled:(NSDate *)date;
- (BOOL)canSelectItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)applyConstraints;

@end

@implementation MNCalendarView

- (void)commonInit {
    self.calendar   = NSCalendar.currentCalendar;
    self.fromDate   = [NSDate.date mn_beginningOfDay:self.calendar];
    self.toDate     = [self.fromDate dateByAddingTimeInterval:MN_YEAR * 4];
    self.daysInWeek = 7;
    self.headerViewClass  = MNCalendarHeaderView.class;
    self.weekdayCellClass = MNCalendarViewWeekdayCell.class;
    self.dayCellClass     = MNCalendarViewDayCell.class;

    self.dateFormat = @"yyyy-MM-dd";
    self.monthFormat = @"yyyy-MM";

    _separatorColor = [UIColor colorWithRed:.85f green:.85f blue:.85f alpha:1.f];
    _calendarBackgroundColor = [UIColor colorWithRed:.96f green:.96f blue:.96f alpha:1.f];
    _disableDateTextColor = _separatorColor;
    _dateBackgroundColor = [UIColor whiteColor];
    _dateTextColor = [UIColor darkTextColor];
    
    _accessibilityDateFormatter = [self iso8601DateFormatter];
    
    [self addSubview:self.collectionView];
    [self applyConstraints];
    [self reloadData];
}

- (NSDateFormatter *)iso8601DateFormatter {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:_dateFormat];
    [dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
    return dateFormatter;
}

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

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (UICollectionView *)collectionView {
    if (nil == _collectionView) {
        MNCalendarViewLayout *layout = [[MNCalendarViewLayout alloc] init];
        
        _collectionView =
        [[UICollectionView alloc] initWithFrame:CGRectZero
                           collectionViewLayout:layout];
        _collectionView.backgroundColor = self.calendarBackgroundColor;
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        
        [self registerUICollectionViewClasses];
    }
    return _collectionView;
}

- (void)setSeparatorColor:(UIColor *)separatorColor {
    _separatorColor = separatorColor;
}

- (void)setCalendar:(NSCalendar *)calendar {
    _calendar = calendar;
    
    self.monthFormatter = [[NSDateFormatter alloc] init];
    self.monthFormatter.calendar = calendar;
    self.monthFormatter.locale = calendar.locale;
    [self.monthFormatter setLocalizedDateFormatFromTemplate:_monthFormat];
}

- (void)setBeginDate:(NSDate *)beginDate
{
    _beginDate = [beginDate mn_beginningOfDay:self.calendar];
}

- (void)setEndDate:(NSDate *)endDate
{
    _endDate = [endDate mn_beginningOfDay:self.calendar];
}

- (void)reloadData {
    NSMutableArray *monthDates = @[].mutableCopy;
    MNFastDateEnumeration *enumeration =
    [[MNFastDateEnumeration alloc] initWithFromDate:[self.fromDate mn_firstDateOfMonth:self.calendar]
                                             toDate:[self.toDate mn_firstDateOfMonth:self.calendar]
                                           calendar:self.calendar
                                               unit:NSMonthCalendarUnit];
    for (NSDate *date in enumeration) {
        [monthDates addObject:date];
    }
    self.monthDates = monthDates;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.calendar = self.calendar;
    
    self.weekdaySymbols = formatter.shortWeekdaySymbols;
    
    [self.collectionView reloadData];
}

- (NSInteger)sectionForDate:(NSDate *)date
{
    if (!date) {
        return nil;
    }
    // User date
    NSDateComponents *components = [self.calendar components:NSCalendarUnitMonth|NSCalendarUnitYear fromDate:date];
    
    // First month
    NSDate *monthDate = self.monthDates[0];
    NSDateComponents *firtSectionComponents = [self.calendar components:NSCalendarUnitMonth|NSCalendarUnitYear fromDate:monthDate];
    
    NSInteger offsetMonth = components.month - firtSectionComponents.month;
    NSInteger offsetYear = components.year - firtSectionComponents.year;
    if (offsetYear > 0) {
        // next year
        
        // this year months + year between + selected month
        offsetMonth = (12 - firtSectionComponents.month) + (offsetYear - 1) * 12 + components.month;
    }
    
    return offsetMonth;
}

- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated
{
    NSInteger offsetMonth = [self sectionForDate:date];
    
    if (!offsetMonth) {
        return;
    }
   
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:offsetMonth];
    
    CGFloat offsetY = [self.collectionView layoutAttributesForSupplementaryElementOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath].frame.origin.y;
    
    CGFloat contentInsetY = self.collectionView.contentInset.top;
    CGFloat sectionInsetY = ((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).sectionInset.top;
    
    [self.collectionView setContentOffset:CGPointMake(self.collectionView.contentOffset.x, offsetY - contentInsetY - sectionInsetY) animated:animated];
}

- (void)registerUICollectionViewClasses {
    [_collectionView registerClass:self.dayCellClass
        forCellWithReuseIdentifier:MNCalendarViewDayCellIdentifier];
    
    [_collectionView registerClass:self.weekdayCellClass
        forCellWithReuseIdentifier:MNCalendarViewWeekdayCellIdentifier];
    
    [_collectionView registerClass:self.headerViewClass
        forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
               withReuseIdentifier:MNCalendarHeaderViewIdentifier];
}

- (NSDate *)firstVisibleDateOfMonth:(NSDate *)date {
    date = [date mn_firstDateOfMonth:self.calendar];
    
    NSDateComponents *components =
    [self.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit
                     fromDate:date];
    
    return
    [[date mn_dateWithDay:-((components.weekday - 1) % self.daysInWeek) calendar:self.calendar] dateByAddingTimeInterval:MN_DAY];
}

- (NSDate *)lastVisibleDateOfMonth:(NSDate *)date {
    date = [date mn_lastDateOfMonth:self.calendar];
    
    NSDateComponents *components =
    [self.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit
                     fromDate:date];
    
    return
    [date mn_dateWithDay:components.day + (self.daysInWeek - 1) - ((components.weekday - 1) % self.daysInWeek)
                calendar:self.calendar];
}

- (void)applyConstraints {
    NSDictionary *views = @{@"collectionView" : self.collectionView};
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[collectionView]|"
                                             options:0
                                             metrics:nil
                                               views:views]
     ];
}

- (BOOL)dateEnabled:(NSDate *)date {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(calendarView:dateAvailable:)]) {
        return [self.delegate calendarView:self dateAvailable:date];
    }
    return YES;
}

- (BOOL)canSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MNCalendarViewCell *cell = (MNCalendarViewCell *)[self collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    
    BOOL enabled = cell.enabled;
    
    if ([cell isKindOfClass:MNCalendarViewDayCell.class] && enabled) {
        MNCalendarViewDayCell *dayCell = (MNCalendarViewDayCell *)cell;
        
        enabled = [self dateEnabled:dayCell.date];
    }
    
    return enabled;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.monthDates.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    MNCalendarHeaderView *headerView =
    [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                       withReuseIdentifier:MNCalendarHeaderViewIdentifier
                                              forIndexPath:indexPath];
    
    headerView.backgroundColor = self.calendarBackgroundColor;
    headerView.titleLabel.text = [self.monthFormatter stringFromDate:self.monthDates[indexPath.section]];
    
    return headerView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSDate *monthDate = self.monthDates[section];
    
    NSDateComponents *components =
    [self.calendar components:NSDayCalendarUnit
                     fromDate:[self firstVisibleDateOfMonth:monthDate]
                       toDate:[self lastVisibleDateOfMonth:monthDate]
                      options:0];
    
    return self.daysInWeek + components.day + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item < self.daysInWeek) {
        MNCalendarViewWeekdayCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:MNCalendarViewWeekdayCellIdentifier
                                                  forIndexPath:indexPath];
        
        cell.backgroundColor = self.calendarBackgroundColor;
        cell.titleLabel.text = self.weekdaySymbols[indexPath.item];
        cell.separatorColor = self.separatorColor;
        return cell;
    }
    
    MNCalendarViewDayCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:MNCalendarViewDayCellIdentifier
                                              forIndexPath:indexPath];
    cell.separatorColor = self.separatorColor;
    
    cell.textColor = self.dateTextColor;
    cell.textBackgroundColor = self.dateBackgroundColor;
    cell.disableTextColor = self.disableDateTextColor;
    cell.disableTextBackgroundColor = self.calendarBackgroundColor;
    
    NSDate *monthDate = self.monthDates[indexPath.section];
    NSDate *firstDateInMonth = [self firstVisibleDateOfMonth:monthDate];
    
    NSUInteger day = indexPath.item - self.daysInWeek;
    
    NSDateComponents *components =
    [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit
                     fromDate:firstDateInMonth];
    components.day += day;
    
    NSDate *date = [self.calendar dateFromComponents:components];
    
    // this setDate will disable date not in this month
    [cell setDate:date
            month:monthDate
         calendar:self.calendar];
    
    [cell setToday:NO];
    
    BOOL isEnable = cell.enabled;
    
    [cell.titleLabel setAccessibilityIdentifier:isEnable ? [_accessibilityDateFormatter stringFromDate:date] : nil];

    if (isEnable) {
        // highligted today
        NSDate *today = [[NSDate date] mn_beginningOfDay:self.calendar];
        if (isEnable && [date isEqualToDate:today]) {
            [cell setToday:YES];
        }
        [cell setEnabled:[self dateEnabled:date]];
    }
    
    [cell setSelected:NO];
    [cell setHighlighted:NO];
    if (self.beginDate && isEnable) {
        if ([date isEqualToDate:self.beginDate]) {
            [cell setSelected:YES];
        }
    }
    
    if (self.endDate && cell.enabled) {
        if ([date isEqualToDate:self.endDate]) {
            [cell setSelected:YES];
        }
    }
    
    if (self.endDate && cell.enabled) {
        if ([date compare:self.beginDate] == NSOrderedDescending &&
            [date compare:self.endDate] == NSOrderedAscending) {
            [cell setHighlighted:YES];
        }
    }

    return cell;
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self canSelectItemAtIndexPath:indexPath];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self canSelectItemAtIndexPath:indexPath]) {
        MNCalendarViewCell *cell = (MNCalendarViewCell *)[self collectionView:collectionView cellForItemAtIndexPath:indexPath];
        if ([cell isKindOfClass:MNCalendarViewDayCell.class] && cell.enabled) {
            MNCalendarViewDayCell *dayCell = (MNCalendarViewDayCell *)cell;
            return [self.delegate calendarView:self shouldSelectDate:dayCell.date];
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MNCalendarViewCell *cell = (MNCalendarViewCell *)[self collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:MNCalendarViewDayCell.class] && cell.enabled) {
        MNCalendarViewDayCell *dayCell = (MNCalendarViewDayCell *)cell;
        
        MNCalendarViewSelectingType type = MNCalendarViewSelectingTypeBeginDate;
        if (self.delegate && [self.delegate respondsToSelector:@selector(calendarViewCurrentSelection:)]) {
            type = [self.delegate calendarViewCurrentSelection:self];
        }
        
        if (type == MNCalendarViewSelectingTypeBeginDate) {
            self.beginDate = dayCell.date;
        } else {
            self.endDate = dayCell.date;
        }
        
        [self.collectionView reloadData];
    
        if (type == MNCalendarViewSelectingTypeBeginDate) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(calendarView:didSelectBeginDate:)]) {
                [self.delegate calendarView:self didSelectBeginDate:dayCell.date];
            }
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(calendarView:didSelectEndDate:)]) {
                [self.delegate calendarView:self didSelectEndDate:dayCell.date];
            }
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width      = self.bounds.size.width;
    CGFloat itemWidth  = roundf(width / self.daysInWeek);
    CGFloat itemHeight = indexPath.item < self.daysInWeek ? 30.f : itemWidth;
    
    NSUInteger weekday = indexPath.item % self.daysInWeek;
    
    if (weekday == self.daysInWeek - 1) {
        itemWidth = width - (itemWidth * (self.daysInWeek - 1));
    }
    
    return CGSizeMake(itemWidth, itemHeight);
}

@end

