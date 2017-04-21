//
//  ViewController.m
//  BZTPropertyAnimationDemo
//
//  Created by Bruce on 17/2/14.
//  Copyright © 2017年 BruceZhu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) UIView *testView;
@property (strong, nonatomic) UIViewPropertyAnimator *viewProperty;
@property (assign, nonatomic) NSInteger animationTime;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.testView = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    self.testView.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.testView];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)beginAnimation:(id)sender {
    __block ViewController *weakself = self;
    if (self.viewProperty.state == UIViewAnimatingStateActive)
    {
        // 从暂停到反转动画
        [self.viewProperty pauseAnimation];
        self.viewProperty.reversed = !self.viewProperty.reversed;
        [self.viewProperty continueAnimationWithTimingParameters:[self timingParameter] durationFactor:0];
    }
    else
    {
        self.testView.frame = CGRectMake(100, 100, 100, 100);
        self.viewProperty = [[UIViewPropertyAnimator alloc] initWithDuration:4.f
                                                            timingParameters:[self timingParameter]];
        switch (self.animationTime % 10) {
            default:
            {
                [self.viewProperty addAnimations:^{
                    weakself.testView.frame = CGRectMake(200, 200, 200, 200);
                }];
            }
                break;
        }
        
        [self.viewProperty addCompletion:^(UIViewAnimatingPosition finalPosition) {
            weakself.animationTime++;
        }];
        [self.viewProperty startAnimation];
    }
    
}

- (id<UITimingCurveProvider>)timingParameter
{
    id<UITimingCurveProvider> timingParameter;
    switch (self.animationTime % 10) {
        case 0:
        {
            timingParameter = [[UISpringTimingParameters alloc] initWithDampingRatio:0.1 initialVelocity:CGVectorMake(0, -10.0)];
        }
            break;
            
        case 1:
        {
            timingParameter = [[UISpringTimingParameters alloc] initWithDampingRatio:0.1 initialVelocity:CGVectorMake(1, 0)];
        }
            break;
        case 2:
        {
            timingParameter = [[UISpringTimingParameters alloc] initWithDampingRatio:0.1 initialVelocity:CGVectorMake(0, 1)];
        }
            break;
        case 3:
        {
            timingParameter = [[UISpringTimingParameters alloc] initWithDampingRatio:0.1 initialVelocity:CGVectorMake(0.3, 0.7)];
        }
            break;
        case 4:
        {
            timingParameter = [[UICubicTimingParameters alloc] initWithControlPoint1:CGPointMake(0, -1) controlPoint2:CGPointMake(1, 2)];
        }
            break;
        case 5:
        {
            timingParameter = [[UICubicTimingParameters alloc] initWithAnimationCurve:UIViewAnimationCurveLinear];
        }
            break;
        case 6:
        {
            timingParameter = [[UICubicTimingParameters alloc] initWithAnimationCurve:UIViewAnimationCurveEaseIn];
        }
            break;
        case 7:
        {
            timingParameter = [[UICubicTimingParameters alloc] initWithAnimationCurve:UIViewAnimationCurveEaseOut];
        }
            break;
            
        default:
        {
            timingParameter = [[UICubicTimingParameters alloc] initWithControlPoint1:CGPointMake(0, -1) controlPoint2:CGPointMake(1, 2)];
        }
            break;
    }
    
    return timingParameter;
}

- (IBAction)pauseAnimation:(id)sender {
    [self.viewProperty pauseAnimation];
}

- (IBAction)continueAnimation:(id)sender {
    //UISpringTimingParameters *param = [[UISpringTimingParameters alloc] initWithDampingRatio:0.1 initialVelocity:CGVectorMake(1.0, 0)];
    [self.viewProperty continueAnimationWithTimingParameters:[self timingParameter] durationFactor:1];
    
}

- (IBAction)stopAnimation:(id)sender {
    [self.viewProperty stopAnimation:true];
    
    __block ViewController *weakself = self;
    [self.viewProperty addAnimations:^{
        weakself.testView.frame = CGRectMake(100, 100, 100, 100);
    } delayFactor:1.f];
}

- (IBAction)processValueChanged:(id)sender {
    UISlider *slider = (UISlider*)sender;
    if (self.viewProperty.state == UIViewAnimatingStateActive)
    {
        self.viewProperty.fractionComplete = slider.value;
    }
}

@end
