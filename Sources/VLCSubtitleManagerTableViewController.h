//
//  VLCSubtitleManagerTableViewController.h
//  VLC for iOS
//
//  Created by Filipe Teixeira on 17/06/14.
//  Copyright (c) 2014 VideoLAN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VLCSubtitleManagerTableViewController : UITableViewController
- (instancetype)initWithMediaPlayer:(VLCMediaPlayer *) mediaPlayer withFileName:(NSString *) filename;

@end
