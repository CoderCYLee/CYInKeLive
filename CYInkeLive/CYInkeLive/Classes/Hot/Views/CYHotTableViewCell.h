//
//  CYHotTableViewCell.h
//  CYInkeLive
//
//  Created by Cyrill on 2017/4/11.
//  Copyright © 2017年 Cyrill. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CYLiveModel;

@interface CYHotTableViewCell : UITableViewCell

@property (nonatomic, strong) CYLiveModel *model;

@end