//
//  CMSteppedProgressBar.m
//
//  Created by Mycose on 12/03/2015.
//  Copyright (c) 2015 Mycose. All rights reserved.
//

#import "CMSteppedProgressBar.h"

@interface CMSteppedProgressBar()
@property (nonatomic, assign) BOOL isAnimated;
@property (nonatomic, strong) NSArray* views;
@property (nonatomic, assign) NSInteger futureStep;
@property (nonatomic, assign) NSInteger futurePosition;
@property (nonatomic, strong) NSArray* filledViews;
@property (nonatomic, strong) NSArray* lineViews;
@property (nonatomic, strong) NSArray* lineFilledViews;
@property (nonatomic, strong) UIView *currentLineView;

@end

@implementation CMSteppedProgressBar

#pragma mark -  Life

- (void)commonInit {
    self.animDuration = 0.6f;
    self.dotsWidth = 20.f;
    self.linesHeight = 5.f;
    self.barColor = [UIColor grayColor];
    self.tintColor = [UIColor whiteColor];
    self.animOption = UIViewAnimationOptionCurveEaseIn;
    self.isAnimated = NO;
    self.futureStep = -1;
    self.futurePosition = -1;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)setNumberOfSteps:(NSUInteger)nbSteps {
    _numberOfSteps = nbSteps;
    [self prepareViews];
    [self setCurrentStep:0];
    [self setCurrentPosition:0];
}

- (void)animateViewFromIndex:(NSUInteger)index toIndex:(NSUInteger)endIndex andInterval:(CGFloat)interval {
    if (index > endIndex) {
        self.isAnimated = NO;
        if (self.futureStep != -1) {
            NSInteger step = self.futureStep;
            self.futureStep = -1;
            [self setCurrentStep:step];
        }
        [self animateViewFromPosition:0 toPosition:_currentPosition andInterval:self.animDuration/10.0];
        if (endIndex==(self.numberOfSteps-1)*2) {
            NSMutableArray *imagesArray = [[NSMutableArray alloc]init];
            for (int i=1; i<7; i++) {
                NSString *imageName = [NSString stringWithFormat:@"glowing_0%d",i];
                UIImage *image = [UIImage imageNamed:imageName];
                [imagesArray addObject:image];
            }
            UIImageView *animationImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.dotsWidth+10, self.dotsWidth+10)];
            animationImage.animationImages = imagesArray;
            animationImage.animationDuration = 0.5f;
            animationImage.animationRepeatCount = 0;
            
            UIView* filledDot = [self.filledViews objectAtIndex:endIndex];
            UIView* notFilledDot = [self.views objectAtIndex:endIndex];
            
            [[notFilledDot viewWithTag:23]setHidden:YES];
            [filledDot setFrame:CGRectMake(filledDot.frame.origin.x-5, filledDot.frame.origin.y-5, self.dotsWidth+10, self.dotsWidth+10)];
            filledDot.backgroundColor = [UIColor clearColor];
            filledDot.layer.cornerRadius = (self.dotsWidth+10)/2;
            
            
            UIImageView *goalStar = [[UIImageView alloc] initWithFrame:CGRectMake(12.5, 12.5, self.dotsWidth-15,self.dotsWidth-15)];
            [goalStar setImage:[UIImage imageNamed:@"goal_star_reached"]];
            goalStar.backgroundColor = [UIColor redColor];
            
            [filledDot addSubview:animationImage];
            [filledDot addSubview:goalStar];
            [animationImage startAnimating];
        }
        return;
    }
    [UIView animateWithDuration:interval delay:0.f options:self.animOption animations:^{
        self.isAnimated = YES;
        UIView* filledDot = [self.filledViews objectAtIndex:index];
        UIView* notFilledDot = [self.views objectAtIndex:index];
        
        [filledDot setFrame:CGRectMake(filledDot.frame.origin.x, filledDot.frame.origin.y, notFilledDot.frame.size.width, filledDot.frame.size.height)];
    }completion:^(BOOL finished){
        [self animateViewFromIndex:index+1 toIndex:endIndex andInterval:interval];
    }];
}

- (void)animateViewFromPosition:(NSUInteger)position toPosition:(NSUInteger)endPosition andInterval:(CGFloat)interval {
    if (position >= endPosition) {
        self.isAnimated = NO;
        if (self.futurePosition != -1) {
            NSInteger pos = self.futurePosition;
            self.futurePosition = -1;
            [self setCurrentPosition:pos];
        }
        return;
    }
    [UIView animateWithDuration:interval delay:0.f options:self.animOption animations:^{
        self.isAnimated = YES;
        UIView* filledLine = [self.lineFilledViews objectAtIndex:position];
        UIView* notFilledLine = [self.lineViews objectAtIndex:position];
        
        [filledLine setFrame:CGRectMake(filledLine.frame.origin.x, filledLine.frame.origin.y, notFilledLine.frame.size.width, filledLine.frame.size.height)];
    }completion:^(BOOL finished){
        [self animateViewFromPosition:position+1 toPosition:endPosition andInterval:interval];
    }];
}

- (void)animateViewInvertFromIndex:(NSUInteger)index toIndex:(NSUInteger)endIndex andInterval:(CGFloat)interval {
    if (index <= endIndex) {
        self.isAnimated = NO;
        if (self.futureStep != -1) {
            NSInteger step = self.futureStep;
            self.futureStep = -1;
            [self setCurrentStep:step];
        }
        return;
    }
    [UIView animateWithDuration:interval delay:0.f options:self.animOption animations:^{
        self.isAnimated = YES;
        UIView* filledDot = [self.filledViews objectAtIndex:index];
        [filledDot setFrame:CGRectMake(filledDot.frame.origin.x, filledDot.frame.origin.y, 0, filledDot.frame.size.height)];
    }completion:^(BOOL finished){
        [self animateViewInvertFromIndex:index-1 toIndex:endIndex andInterval:interval];
    }];
}

- (void)setCurrentStep:(NSUInteger)currentStep andCurrentPosition:(NSUInteger)currentPosition{
    _currentPosition = currentPosition;
    if (self.isAnimated == NO) {
        if (currentStep < self.numberOfSteps) {
            if (currentStep != _currentStep) {
                if (_currentStep < currentStep)
                {
                    if (currentStep == 0) {
                        [[self.views objectAtIndex:0] setBackgroundColor:self.tintColor];
                        self.currentLineView = [self.filledViews objectAtIndex:(currentStep*2+1)%9];
                        UIView *lineView = [self.views objectAtIndex:(currentStep*2+1)%9];
                        [self.currentLineView setFrame:CGRectMake(self.currentLineView.frame.origin.x, self.currentLineView.frame.origin.y, lineView.frame.size.width, self.currentLineView.frame.size.height)];
                        if (currentStep!=self.numberOfSteps-1) {
                            [self prepareLineViews];
                            [self animateViewFromPosition:0 toPosition:currentPosition andInterval:self.animDuration/10.0];
                        }
                    } else {
                        NSUInteger diff = currentStep - _currentStep;
                        [self animateViewFromIndex:_currentStep*2 toIndex:(_currentStep*2)+diff*2 andInterval:self.animDuration/(CGFloat)diff];
                        self.currentLineView = [self.filledViews objectAtIndex:(currentStep*2+1)%9];
                        UIView *lineView = [self.views objectAtIndex:(currentStep*2+1)%9];
                        [self.currentLineView setFrame:CGRectMake(self.currentLineView.frame.origin.x, self.currentLineView.frame.origin.y, lineView.frame.size.width, self.currentLineView.frame.size.height)];
                        if (currentStep!=self.numberOfSteps-1) {
                            [self prepareLineViews];
                        }
                    }
                }
                else {
                    if (_currentStep == -1) {
                        [[self.views objectAtIndex:0] setBackgroundColor:self.tintColor];
                    } else {
                        NSUInteger diff = _currentStep - currentStep;
                        [self animateViewInvertFromIndex:_currentStep*2 toIndex:(_currentStep*2)-diff*2 andInterval:self.animDuration/(CGFloat)diff];
                    }
                }
            }else{
                self.currentLineView = [self.filledViews objectAtIndex:(currentStep*2+1)%9];
                UIView *lineView = [self.views objectAtIndex:(currentStep*2+1)%9];
                [self.currentLineView setFrame:CGRectMake(self.currentLineView.frame.origin.x, self.currentLineView.frame.origin.y, lineView.frame.size.width, self.currentLineView.frame.size.height)];
                if (currentStep!=self.numberOfSteps-1) {
                    [self prepareLineViews];
                    [self animateViewFromPosition:0 toPosition:currentPosition andInterval:self.animDuration/10.0];
                }
            }
            _currentStep = currentStep;
        }
        
    }
    else {
        self.futureStep = currentStep;
    }
}

- (void)nextStep {
    if (self.currentStep != self.numberOfSteps)
        [self setCurrentStep:self.currentStep+1];
}

- (void)prevStep {
    if (self.currentStep != -1)
        [self setCurrentStep:self.currentStep-1];
}

- (void)stepBtnClicked:(id)sender
{
    UITapGestureRecognizer *gesture = sender;
    [self.delegate steppedBar:self didSelectIndex:[gesture.view tag]];
}

- (void) prepareViews {
    NSMutableArray* aviews = [[NSMutableArray alloc] init];
    NSMutableArray* afilledViews = [[NSMutableArray alloc] init];
    
    CGFloat padding = (self.frame.size.width-(self.numberOfSteps*self.dotsWidth))/(self.numberOfSteps+1);
    for (int i = 0; i < self.numberOfSteps; i++) {
        UIView *round = [[UIView alloc] initWithFrame:CGRectMake((i*self.dotsWidth)+((i+1)*padding), self.frame.size.height/2-self.dotsWidth/2, self.dotsWidth, self.dotsWidth)];
        round.tag = i;
        round.layer.cornerRadius = self.dotsWidth/2;
        if (i == 0)
            round.backgroundColor = self.tintColor;
        else
            round.backgroundColor = self.barColor;
        
        UIView* filledround = [[UIView alloc] initWithFrame:CGRectMake((i*self.dotsWidth)+((i+1)*padding), self.frame.size.height/2-self.dotsWidth/2, 0, self.dotsWidth)];
        filledround.backgroundColor = self.tintColor;
        filledround.layer.cornerRadius = self.dotsWidth/2;
        filledround.layer.masksToBounds = NO;
        filledround.userInteractionEnabled = NO;
        
        if ((i+1)<self.numberOfSteps && i>0) {
            UILabel *mileStoneNumber = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.dotsWidth, self.dotsWidth)];
            mileStoneNumber.textColor = [UIColor blackColor];
            mileStoneNumber.font = [mileStoneNumber.font fontWithSize:18];
            mileStoneNumber.text = [NSString stringWithFormat:@"%d",i+1];
            mileStoneNumber.textAlignment = NSTextAlignmentCenter;
            [round addSubview:mileStoneNumber];
        }else if(i!=0)
        {
            UIImageView *goalStar = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, (self.dotsWidth-4), (self.dotsWidth-4))];
            goalStar.tag = 23;
            [goalStar setImage:[UIImage imageNamed:@"goal_star"]];
            [round addSubview:goalStar];
        }
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stepBtnClicked:)];
        [round addGestureRecognizer:recognizer];
        
        [afilledViews addObject:filledround];
        [aviews addObject:round];
        if (i < self.numberOfSteps-1) {
            UIView* line = [[UIView alloc] initWithFrame:CGRectMake((round.frame.origin.x+round.frame.size.width)-1, self.frame.size.height/2-self.linesHeight/2, padding+2, self.linesHeight)];
            line.backgroundColor = self.barColor;
            [self addSubview:line];
            [aviews addObject:line];
            
            UIView* filledline = [[UIView alloc] initWithFrame:CGRectMake((round.frame.origin.x+round.frame.size.width)-1, self.frame.size.height/2-self.linesHeight/2, 0, self.linesHeight)];
            filledline.backgroundColor = self.tintColor;
            [self addSubview:filledline];
            [afilledViews addObject:filledline];
        }
        [self addSubview:round];
        [self addSubview:filledround];
    }
    self.views = aviews;
    self.filledViews = afilledViews;
}

- (void) prepareLineViews {
    NSMutableArray* lviews = [[NSMutableArray alloc] init];
    NSMutableArray* lfilledViews = [[NSMutableArray alloc] init];
    
    CGFloat lineWidth = _currentLineView.frame.size.width/10;
    for (int i = 0; i < 10; i++) {
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(lineWidth*i, 0, lineWidth, self.linesHeight)];
        line.backgroundColor = self.barColor;
        [lviews addObject:line];
        
        UIView* filledline = [[UIView alloc] initWithFrame:CGRectMake(lineWidth*i, 0, 0, self.linesHeight)];
        filledline.backgroundColor = self.tintColor;
        [lfilledViews addObject:filledline];
        [_currentLineView addSubview:line];
        [_currentLineView addSubview:filledline];
    }
    self.lineViews = lviews;
    self.lineFilledViews = lfilledViews;
}


@end
