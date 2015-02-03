//
//  UIImage+BareFeetWare.h
//
//  Created by Tom Brodhurst-Hill on 5/03/12.
//  Copyright (c) 2012 BareFeetWare. All rights reserved.
//  Permission granted for use by CBA.
//

#import <UIKit/UIKit.h>

@interface UIImage (BareFeetWare)

- (UIImage*)maskWithImage:(UIImage*)maskImage;
+ (UIImage*)imageOfView:(UIView*)view size:(CGSize)size;

@end