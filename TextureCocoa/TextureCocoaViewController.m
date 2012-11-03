//
//  TextureCocoaViewController.m
//  TextureCocoa
//
//  Created by Tau Nicholas on 11/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TextureCocoaViewController.h"
#import "TexureManager.h"
@interface TextureCocoaViewController ()

@end

@implementation TextureCocoaViewController
@synthesize sv_content;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
//    [[TexureManager shareInstance] addTextureFile:@"tx_ready"
//                                         isRetina:FALSE];
    NSString * path = [[NSBundle mainBundle] pathForResource:@"bird1-50" ofType:@"png"];
    UIImage * src = [[UIImage alloc] initWithContentsOfFile:path];
    UIImage * image = [TexureManager createImageFrom:src.CGImage
                                    destinationWidth:200
                                   destinationHeight:200 
                                              offset:CGPointMake(20, 10)
                                               scale:1
                                         orientation:UIImageOrientationUp];
    UIImageView * iv =[[UIImageView alloc] initWithImage:image];
    [sv_content addSubview:iv];
    [iv release];
    
    
    return;
    int y=0;
    for (UIImage * image in [[TexureManager shareInstance] getAllImages])
    {
        UIImageView * iv =[[UIImageView alloc] initWithImage:image];
        y+=image.size.height;
        iv.frame  =CGRectMake(0, y, image.size.width, image.size.height);
        [sv_content addSubview:iv];
        [iv release];
    }
    sv_content.contentSize =CGSizeMake(320, y);
    return;
}

- (void)viewDidUnload
{
    [self setSv_content:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)addImage:(id)sender 
{
    [[TexureManager shareInstance] addTextureFile:@"tx_ready" isRetina:NO];
    
    UIImage * image = [[TexureManager shareInstance] getUIImageByName:@"Helpbutton_Page_1.png"];
    UIImageView * iv =[[UIImageView alloc] initWithImage:image];
    [self.view addSubview:iv];
    [iv release];

}
- (void)dealloc {
    [sv_content release];
    [super dealloc];
}
@end
