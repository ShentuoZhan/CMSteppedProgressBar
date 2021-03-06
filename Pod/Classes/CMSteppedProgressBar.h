//
//  CMSteppedProgressBar.h
//  brainapp
//
//  Created by Tom on 12/03/2015.
//  Last Modified by Shentuo Zhan on 02/12/2015.
//  Copyright (c) 2015 Tom. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CMSteppedProgressBar;
@protocol CMSteppedProgressBarDelegate <NSObject>
- (void)steppedBar:(CMSteppedProgressBar *)steppedBar didSelectIndex:(NSUInteger)index;
@end

@interface CMSteppedProgressBar : UIView

/// set numberOfSteps in last because it will create all views, so if you want a custom design customize before setting the number of steps
@property (nonatomic) NSUInteger numberOfSteps;

///set munaully the different distances of milestones
@property (nonatomic, strong) NSMutableArray *mileStones;

/// set manually the currentStep or use stepNext/stepPrev
@property (nonatomic) NSUInteger currentStep;

/// set manually the current position between currentStep and nextStep [0, 100]
@property (nonatomic) NSUInteger currentPosition;

/// change the line height between the dots, default is 5
@property (nonatomic) CGFloat linesHeight;

/// change the width of the dots, default is 20
@property (nonatomic) CGFloat dotsWidth;

/// anim duration, default is 0.6f
@property (nonatomic) NSTimeInterval animDuration;

/// anim type, default is curve ease in
@property (nonatomic) UIViewAnimationOptions animOption;

/// change the color of the bar when not filled, gray by default
@property (nonatomic, strong) UIColor* barColor;

/// change the color of the bar when it's filled, white by default
@property (nonatomic, strong) UIColor* tintColor;

@property (nonatomic, weak) id<CMSteppedProgressBarDelegate> delegate;

- (void)nextStep;
- (void)prevStep;
- (void)setNumberOfSteps:(NSUInteger)nbSteps withMileStones:(NSMutableArray*)mileStones;
- (void)setCurrentStep:(NSUInteger)currentStep andCurrentPosition:(NSUInteger)currentPosition;
@end
