//
//  TWViewController.m
//  TechWeekTimetable
//
//  Created by Robert Lis on 03/03/2014.
//  Copyright (c) 2014 Robert Lis. All rights reserved.
//

#import "TWViewController.h"
#import "TWTalkTableViewCell.h"
#import "TWTalkDayTableViewHeader.h"
#import "TWFullTalkTableViewCell.h"

@interface TWViewController () <UITableViewDataSource, UITableViewDelegate>
@property NSMutableDictionary *daysToTalks;
@property NSMutableArray *days;
@property NSDateFormatter *dateFormatter;
@property NSDateFormatter *timeFormatter;
@property NSIndexPath *selectedCellPath;
@end

@implementation TWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupTable];
    [self setupFormatters];
    [self setupData];
}

-(void)setupTable
{
    [self.tableView registerNib:[UINib nibWithNibName:@"TWTalkDayTableViewHeader" bundle:nil] forHeaderFooterViewReuseIdentifier:@"day_header"];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

-(void)setupFormatters
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter = dateFormatter;
    self.dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    self.dateFormatter.locale = [NSLocale currentLocale];
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    self.timeFormatter = timeFormatter;
    self.timeFormatter.dateFormat = @"HH:mm";
    self.timeFormatter.locale = [NSLocale currentLocale];
}

-(void)setupData
{
    NSString *pathToTimetable = [[NSBundle mainBundle] pathForResource:@"timetable" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:pathToTimetable];
    [self initDaysFromTimetable:[NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil]];
}

-(void)initDaysFromTimetable:(NSArray *)timetable
{
    self.daysToTalks = [NSMutableDictionary dictionary];
    self.days = [NSMutableArray array];
    
    NSDateFormatter *dayOfWeekFormatter = [[NSDateFormatter alloc] init];
    dayOfWeekFormatter.dateFormat = @"EEEE";
    
    for(NSDictionary *talk in timetable)
    {
        NSString *dateString = talk[@"time"];
        NSDate *date = [self.dateFormatter dateFromString:dateString];
        NSString *dayOfWeek = [dayOfWeekFormatter stringFromDate:date];
        if([self.days indexOfObject:dayOfWeek] == NSNotFound)
        {
            [self.days addObject:dayOfWeek];
            NSMutableArray *talks = [NSMutableArray arrayWithObject:talk];
            [self.daysToTalks setObject:talks forKey:dayOfWeek];
        }
        else
        {
            [self.daysToTalks[dayOfWeek] addObject:talk];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   return self.days.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *day = self.days[section];
    NSArray *talks = self.daysToTalks[day];
    return talks.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 80.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.selectedCellPath isEqual:indexPath])
    {
        NSDictionary *talk = self.daysToTalks[self.days[indexPath.section]][indexPath.row];
        CGFloat textHeight = [self heightForText:talk[@"blurb"] sizeWithFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody] constrainedToWidth:280];
        return 100 + 40 + textHeight;
    }
    else
    {
        return 100.0f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TWTalkTableViewCell *cell;

    if(![indexPath isEqual:self.selectedCellPath])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"table_cell" forIndexPath:indexPath];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"table_cell_large" forIndexPath:indexPath];
    }
    
    NSDictionary *talk = self.daysToTalks[self.days[indexPath.section]][indexPath.row];
    cell.titleLabel.text = talk[@"title"];
    cell.venueLabel.text = talk[@"venue"];
    NSString *dateString = talk[@"time"];
    NSDate *date = [self.dateFormatter dateFromString:dateString];
    cell.timeLabel.text = [self.timeFormatter stringFromDate:date];
    if([cell isKindOfClass:[TWFullTalkTableViewCell class]])
    {
        [cell setValue:talk[@"blurb"] forKeyPath:@"descriptionLabel.text"];
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    TWTalkDayTableViewHeader *header = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"day_header"];
    header.contentView.backgroundColor = [UIColor whiteColor];
    header.dayLabel.text = self.days[section];
    return header;
}

-(CGFloat)heightForText:(NSString*)text sizeWithFont:(UIFont*)font constrainedToWidth:(CGFloat)width
{
    NSDictionary *attributesDictionary = @{NSFontAttributeName : font};
    CGRect frame = [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                      options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                   attributes:attributesDictionary
                                      context:nil];
    return ceilf(frame.size.height);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.selectedCellPath isEqual:indexPath])
    {
        [self.tableView beginUpdates];
        self.selectedCellPath = nil;
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
    else if(self.selectedCellPath)
    {
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[self.selectedCellPath, indexPath] withRowAnimation:UITableViewRowAnimationFade];
         self.selectedCellPath = indexPath;
        [self.tableView endUpdates];
    }
    else
    {
        self.selectedCellPath = indexPath;
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];        
        [self.tableView endUpdates];
    }
}

@end
