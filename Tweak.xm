@interface PUCropToolController : UIViewController
@property (nonatomic, retain) UIView *_cropView;

- (void)resetToDefaultValueAnimated:(BOOL)reset;
- (BOOL)canResetToDefaultValue;

- (BOOL)_hasAutoAppliedCropSuggestion;
- (void)_applyCropSuggestion;
@end

%hook PUCropToolController

// Crop rect view frame
- (void)_setViewCropRect:(CGRect)frame normalizedImageRect:(CGRect)normFrame {
    CGRect newFrame = CGRectMake(frame.origin.x,
                                 MAX(50, frame.origin.y),
                                 frame.size.width,
                                 frame.size.height);
    %orig(newFrame, normFrame);
}

- (void)_setViewCropRect:(CGRect)frame normalizedImageRect:(CGRect)normFrame animated:(BOOL)animate {
    CGRect newFrame = CGRectMake(frame.origin.x,
                                 MAX(50, frame.origin.y),
                                 frame.size.width,
                                 frame.size.height);
    %orig(newFrame, normFrame, animate);
}

- (CGRect)_cropCanvasFrame {
    CGRect orig = %orig;

    return CGRectMake(orig.origin.x,
                      orig.origin.y + 40,
                      orig.size.width,
                      orig.size.height);
}

// Remove reset / auto button
- (void)_updateCropToggleConstraintsIfNeeded {
    return;
}

- (void)_updateCropToggleButton {
    return;
}

// Add reset / auto gesture
- (void)viewDidLoad {
    %orig;

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self._cropView addGestureRecognizer:longPress];
    [longPress release];
}

%new
- (void)longPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if ([self canResetToDefaultValue]) {
            [self resetToDefaultValueAnimated:YES];
        } else if ([self _hasAutoAppliedCropSuggestion]) {
            [self _applyCropSuggestion];
        }
    }
}

%end
