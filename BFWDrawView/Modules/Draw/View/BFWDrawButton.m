//
//  BFWDrawButton.m
//
//  Created by Tom Brodhurst-Hill on 4/12/2014.
//  Copyright (c) 2014 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

#import "BFWDrawButton.h"
#import "BFWDrawView.h"

@implementation NSMutableDictionary (BFWDraw)

- (void)setValueOrRemoveNil:(id)valueOrNil forKey:(id)key
{
    if (valueOrNil) {
        self[key] = valueOrNil;
    }
    else {
        [self removeObjectForKey:key];
    }
}

@end

@interface BFWDrawButton ()

@property (nonatomic, strong) NSMutableDictionary *iconDrawViewForStateDict;
@property (nonatomic, strong) NSMutableDictionary *backgroundDrawViewForStateDict;

@end

@implementation BFWDrawButton

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (!CGSizeEqualToSize(frame.size, CGSizeZero)) {
            [self commonInit];
        }
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)prepareForInterfaceBuilder
{
    [self commonInit];
}

- (void)commonInit
{
    // implement in subclasses if required
}

#pragma mark - accessors

- (NSMutableDictionary *)iconDrawViewForStateDict
{
    if (!_iconDrawViewForStateDict) {
        _iconDrawViewForStateDict = [[NSMutableDictionary alloc] init];
    }
    return _iconDrawViewForStateDict;
}

- (NSMutableDictionary *)backgroundDrawViewForStateDict
{
    if (!_backgroundDrawViewForStateDict) {
        _backgroundDrawViewForStateDict = [[NSMutableDictionary alloc] init];
    }
    return _backgroundDrawViewForStateDict;
}

#pragma mark - accessors for state

- (BFWDrawView *)iconDrawViewForState:(UIControlState)state
{
    return self.iconDrawViewForStateDict[@(state)];
}

- (BFWDrawView *)backgroundDrawViewForState:(UIControlState)state
{
    return self.backgroundDrawViewForStateDict[@(state)];
}

- (void)setIconDrawView:(BFWDrawView *)drawView
               forState:(UIControlState)state
{
    [self.iconDrawViewForStateDict setValueOrRemoveNil:drawView
                                             forKey:@(state)];
    [self setImage:drawView.image forState:state];
}

- (void)setBackgroundDrawView:(BFWDrawView *)drawView
                     forState:(UIControlState)state
{
    [self.backgroundDrawViewForStateDict setValueOrRemoveNil:drawView
                                                   forKey:@(state)];
}

@end
