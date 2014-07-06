//
//  VLCSubtitleLangTableViewCell.h
//  VLC for iOS
//
//  Created by Filipe Teixeira on 06/07/14.
//  Copyright (c) 2014 VideoLAN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VLCSubtitleLangTableViewCell : UITableViewCell
@property (nonatomic, retain) UISwitch * langSwitch;

@property (nonatomic, copy) void(^switchHasChanged)(BOOL);
@end
