//
//  BFWDrawButton.m
//
//  Created by Tom Brodhurst-Hill on 4/12/2014.
//  Copyright (c) 2014 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

#import "BFWDrawButton.h"
#import "BFWDrawView.h"
#import "UIView+BFW.h"
#import "BFWStyleKit.h"
#import "BFWStyleKitDrawing.h"

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
@property (nonatomic, strong) NSMutableDictionary *shadowForStateDict;
@property (nonatomic, assign) BOOL needsUpdateShadow;
@property (nonatomic, readonly) BOOL needsUpdateBackgrounds;
@property (nonatomic, assign) CGSize backgroundSize;

@end

@implementation BFWDrawButton

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
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

- (void)commonInit
{
    // implement in subclasses if required and call super
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

- (NSMutableDictionary *)shadowForStateDict
{
    if (!_shadowForStateDict) {
        _shadowForStateDict = [[NSMutableDictionary alloc] init];
    }
    return _shadowForStateDict;
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
    [self.backgroundDrawViewForStateDict setValueOrRemoveNil:drawView.canDraw ? drawView : nil
                                                      forKey:@(state)];
    [self setNeedsUpdateBackgrounds];
}

- (void)makeIconDrawViewsFromStateNameDict:(NSDictionary *)stateNameDict
                                  styleKit:(NSString *)styleKit
{
    self.iconDrawViewForStateDict = nil;
    for (NSNumber *stateNumber in stateNameDict) {
        BFWStyleKitDrawing *drawing = [BFWStyleKit drawingForStyleKitName:styleKit
                                                              drawingName:stateNameDict[stateNumber]];
        BFWDrawView *icon = [[BFWDrawView alloc] initWithFrame:drawing.intrinsicFrame];
        icon.drawing = drawing;
        icon.tintColor = self.tintColor;
        icon.contentMode = UIViewContentModeRedraw;
        [self setIconDrawView:icon
                     forState:stateNumber.integerValue];
    }
}

- (void)makeBackgroundDrawViewsFromStateNameDict:(NSDictionary *)stateNameDict
                                        styleKit:(NSString *)styleKit
{
    self.backgroundDrawViewForStateDict = nil;
    for (NSNumber *stateNumber in stateNameDict) {
        BFWDrawView *background = [[BFWDrawView alloc] initWithFrame:self.bounds];
        background.name = stateNameDict[stateNumber];
        background.styleKit = styleKit;
        background.contentMode = UIViewContentModeRedraw;
        [self setBackgroundDrawView:background
                           forState:stateNumber.integerValue];
    }
}

- (NSShadow *)shadowForState:(UIControlState)state
{
    return self.shadowForStateDict[@(state)];
}

- (void)setShadow:(NSShadow *)shadow
         forState:(UIControlState)state
{
    [self.shadowForStateDict setValueOrRemoveNil:shadow
                                          forKey:@(state)];
    [self setNeedsUpdateShadow];
}

- (void)setNeedsUpdateShadow
{
    self.needsUpdateShadow = YES;
    [self setNeedsDisplay];
}

- (void)setNeedsUpdateBackgrounds
{
    self.backgroundSize = CGSizeZero;
    [self setNeedsLayout];
}

- (BOOL)needsUpdateBackgrounds
{
    return !CGSizeEqualToSize(self.backgroundSize, self.bounds.size);

}

#pragma mark - updates

- (void)updateBackgrounds
{
    for (NSNumber *stateNumber in @[@(UIControlStateNormal), @(UIControlStateDisabled), @(UIControlStateSelected), @(UIControlStateHighlighted)])
    {
        BFWDrawView *background = self.backgroundDrawViewForStateDict[stateNumber];
        background.frame = self.bounds;
        [self setBackgroundImage:background.image forState:stateNumber.integerValue];
    }
}

- (void)updateBackgroundsIfNeeded
{
    if (self.needsUpdateBackgrounds) {
        self.backgroundSize = self.bounds.size;
        [self updateBackgrounds];
    }
}

- (void)updateShadowIfNeeded
{
    if (self.needsUpdateShadow) {
        self.needsUpdateShadow = NO;
        NSShadow *shadow = [self shadowForState:self.state];
        if (!shadow) {
            shadow = [self shadowForState:UIControlStateNormal];
        }
        [self applyShadow:shadow];
    }
}

#pragma mark - UIButton

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self setNeedsUpdateShadow];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self setNeedsUpdateShadow];
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    [self setNeedsUpdateShadow];
}

#pragma mark - UIView

- (void)layoutSubviews
{
    [self updateBackgroundsIfNeeded];
    [super layoutSubviews];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [self updateShadowIfNeeded];
}

@end
