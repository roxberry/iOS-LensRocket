//
//  TallNavBar.m
//  LensRocket
//
//  Created by Chris Risner on 1/20/14.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import "TallNavBar.h"

@interface TallNavBar ()

@property (nonatomic) int customHeight;

@end

@implementation TallNavBar



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(id)initWithCoder:(NSCoder *)aDecoder {
//    return [super initWithCoder:aDecoder];
//    TallNavBar *navBar = [[TallNavBar alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
//    return navBar;
    self.customHeight = 55;
    TallNavBar *navBar = [super initWithCoder:aDecoder];
    [navBar setFrame:CGRectMake(0, 0, 320, self.customHeight)];
    return navBar;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    size.width = self.frame.size.width;
    size.height = self.customHeight;
    return size;
}

-(void)setBounds:(CGRect)bounds {
    
    [super setBounds:bounds];
    self.frame = CGRectMake(0, 0, 320, self.customHeight);
    
    
}



@end
