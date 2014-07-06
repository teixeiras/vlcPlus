//
//  VLCSubtitleLangTableViewCell.m
//  VLC for iOS
//
//  Created by Filipe Teixeira on 06/07/14.
//  Copyright (c) 2014 VideoLAN. All rights reserved.
//

#import "VLCSubtitleLangTableViewCell.h"

@implementation VLCSubtitleLangTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.langSwitch = [UISwitch new];
        [self.langSwitch addTarget:self action:@selector(valueAsChanged:) forControlEvents:UIControlEventValueChanged];
        
        self.accessoryView = self.langSwitch;
    }
    return self;
}
-(void) valueAsChanged:(UISwitch *) langSwitch
{
    (self.switchHasChanged)(langSwitch.isOn);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
