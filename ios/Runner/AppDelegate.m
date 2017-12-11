@import GoogleMaps;
#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <QuartzCore/CAEAGLLayer.h>


CALayer *createLayer(UIColor *color, int offset) {
    Surface *surface = [[Surface alloc] init];
    CALayer *layer = surface.layer;
    layer.backgroundColor = [color CGColor];
    layer.frame = CGRectMake(offset, offset, 100, 100);
    [surface updateStorage];
    __block int i = 0;
    [NSTimer scheduledTimerWithTimeInterval: 1 repeats:true block:^(NSTimer * _Nonnull timer) {
        [surface draw: [NSString stringWithFormat: @"%d %d", offset, i]];
        i++;
    }];
    return layer;
}


@interface GestureForwardingView : UIView
@property (nonatomic) UIView *receivingView;
@end

@implementation GestureForwardingView
-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return [_receivingView hitTest:point withEvent:event];
}
@end

@interface ClipLayer : CALayer
@property (readonly, nonatomic) CGRect rect;
@end

@implementation ClipLayer
-(id)initWithRect:(CGRect) rect {
    self = [super init];
    if (self) {
        _rect = rect;
    }
    return self;
}

-(void)drawInContext:(CGContextRef)ctx {
    CGContextSaveGState(ctx);
    CGContextClipToRect(ctx, _rect);
    [super drawInContext:ctx];
    CGContextRestoreGState(ctx);
}

@end

@implementation AppDelegate
{
    GMSMapView* mapView;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
    
  [GMSServices provideAPIKey:@"AIzaSyBT9AN5FBgBfc4f_OtHwIu_wFs8XOIIT4U"];

  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

//-(void)onTap:(UITapGestureRecognizer *)sender{
//    if (sender.state == UIGestureRecognizerStateEnded)
//    {
//        mapView.
//    }
//}

- (void)applicationDidBecomeActive:(UIApplication *)application {
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.868
                                                                longitude:151.2086
                                                                     zoom:10];
    NSLog(@"Opening Map");
        mapView = [GMSMapView mapWithFrame:CGRectMake(0, 0, 400, 500) camera:camera];
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = camera.target;
        marker.snippet = @"Hello World";
        marker.appearAnimation = kGMSMarkerAnimationPop;
        marker.map = mapView;
    CALayer* clipLayer = [[CALayer alloc] init];
    
    clipLayer.frame = CGRectMake(75, 75, 125, 125);
    clipLayer.masksToBounds = true;
    GestureForwardingView* forwardingView = [[GestureForwardingView alloc] initWithFrame:self.window.rootViewController.view.frame];
    forwardingView.receivingView = mapView;
    forwardingView.backgroundColor = [UIColor brownColor];
    [forwardingView addSubview: mapView];
    UIView* flutterView = self.window.rootViewController.view;
    self.window.rootViewController.view = forwardingView;
    [forwardingView addSubview:flutterView];
    [flutterView addSubview: mapView];
    
    [flutterView.layer addSublayer: clipLayer];
        [clipLayer addSublayer:createLayer([UIColor greenColor], 40)];
        [clipLayer addSublayer:mapView.layer];
        [clipLayer addSublayer:createLayer([UIColor redColor], 60)];
    
}


@end
