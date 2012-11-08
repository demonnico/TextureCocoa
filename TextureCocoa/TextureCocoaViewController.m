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
    
    
    [[TexureManager shareInstance] addTextureFile:@"demo_texture"];
   
    int y=0;
    for (UIImage * image in [[TexureManager shareInstance] getAllImages])
    {
        UIImageView * iv =[[UIImageView alloc] initWithImage:image];
        iv.frame  =CGRectMake(0, y, image.size.width, image.size.height);
        [sv_content addSubview:iv];
        [iv release];
        y+=image.size.height;
        y+=10;
    }
    sv_content.contentSize =CGSizeMake(320, y);
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

- (void)dealloc {
    [sv_content release];
    [super dealloc];
}
@end
