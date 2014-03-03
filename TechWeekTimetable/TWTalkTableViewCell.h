//
//  TWTalkTableViewCell.h
//  TechWeekTimetable
//
//  Created by Robert Lis on 03/03/2014.
//  Copyright (c) 2014 Robert Lis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TWTalkTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *venueLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@end
