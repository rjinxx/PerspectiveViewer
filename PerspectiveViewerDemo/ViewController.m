//
//  ViewController.m
//  PerspectiveViewerDemo
//
//  Created by Rylan on 3/12/15.
//  Copyright (c) 2015 ArcSoft. All rights reserved.
//

#import "ViewController.h"

#define TRANS_SIZE          120
#define ORIGINAL_Y          30
#define USING_CASHAPELAYER  0

@interface ViewController ()

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIImageView *transView;
@property (strong, nonatomic) CAShapeLayer *shapeLayer;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view setBackgroundColor:[UIColor grayColor]];
    
    CGRect rect = self.view.frame;
    rect.origin.y += ORIGINAL_Y; rect.size.height -= ORIGINAL_Y*2;
    
    // ****************************************************************************************** //
    // *Perspective Viewer can also be implemented using CAShapeLayer combined with UIBezierPath *//
    // ****************************************************************************************** //
    
    // Set 'USING_CASHAPELAYER' to 1 and see how it is implemented
    
    #if USING_CASHAPELAYER
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
    [imageView setImage:[UIImage imageNamed:@"test_image"]];
    [imageView setUserInteractionEnabled:YES];
    [imageView setClipsToBounds:YES]; [self.view addSubview:imageView];
    
    CGPoint point = CGPointMake(rect.size.width/2.f, rect.size.height/2.f);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:point
                                                        radius:TRANS_SIZE/2.f
                                                    startAngle:0
                                                      endAngle:2*M_PI
                                                     clockwise:YES];
    
    CAShapeLayer *shape = [CAShapeLayer layer]; shape.path = path.CGPath;
    imageView.layer.mask = shape; [self setShapeLayer:shape];
    
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                             action:@selector(panAction:)];
    [imageView addGestureRecognizer:panGes];
    
    #else
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TRANS_SIZE, TRANS_SIZE)];
    [bgView.layer setCornerRadius:TRANS_SIZE/2.f]; [bgView setClipsToBounds:YES];
    [self.view addSubview:bgView]; [self setBackgroundView:bgView];
    [bgView setCenter:self.view.center];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:[self.view convertRect:rect toView:bgView]];
    [imageView setImage:[UIImage imageNamed:@"test_image"]];
    [imageView setBackgroundColor:[UIColor brownColor]];
    [bgView addSubview:imageView]; [self setTransView:imageView];
    
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc]   initWithTarget:self
                                                                               action:@selector(panAction:)];
    [bgView addGestureRecognizer:panGes];
    
    #endif
}

- (void)panAction:(UIPanGestureRecognizer *)sender
{
    CGFloat supposedX = [sender translationInView:self.view].x;
    CGFloat supposedY = [sender translationInView:self.view].y;
    
    #if USING_CASHAPELAYER
    
    [CATransaction setDisableActions:YES];
    
    CGPoint bgRect = self.shapeLayer.position;
    
    CGFloat xEage = sender.view.bounds.size.width /2.f - TRANS_SIZE/2.f;
    CGFloat yEage = sender.view.bounds.size.height/2.f - TRANS_SIZE/2.f;
    
    if (bgRect.x + supposedX >= -xEage && bgRect.x + supposedX <= xEage)
    {
        bgRect.x += supposedX;
    }
    
    if (bgRect.y + supposedY >= -yEage && bgRect.y + supposedY <= yEage)
    {
        bgRect.y += supposedY;
    }
    
    self.shapeLayer.position = bgRect;
    
    #else
    
    CGRect bgRect    = self.backgroundView.frame;
    CGRect transRect = self.transView.frame;
    
    if (bgRect.origin.x + supposedX >= 0 &&
        bgRect.origin.x + supposedX + bgRect.size.width  <= transRect.size.width)
    {
        bgRect.origin.x    += supposedX;
        transRect.origin.x -= supposedX;
    }
    
    CGFloat endLength = bgRect.origin.y + supposedY + bgRect.size.height;
    if (bgRect.origin.y + supposedY >= ORIGINAL_Y &&
                          endLength <= transRect.size.height + ORIGINAL_Y)
    {
        bgRect.origin.y    += supposedY;
        transRect.origin.y -= supposedY;
    }
    
    [self.backgroundView setFrame:bgRect];
    [self.transView setFrame:transRect];
    
    #endif
    
    [sender setTranslation:CGPointZero inView:self.view];
}

- (void)dealloc
{
    self.backgroundView = nil;
    self.transView = nil;
    self.shapeLayer = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end