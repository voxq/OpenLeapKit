//
//  LeapMenuView.h
//
//  Created by Tyler Zetterstrom on 2013-11-25.
//  Copyright (c) 2013 Tyler Zetterstrom. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum
{
    LeapMenuItemOptions = 1,
    LeapMenuItemTypingMode = 2,
    LeapMenuItemCharSets = 3,
    LeapMenuItemLayout = 4
}LeapMenuItem;

@protocol LeapMenuDelegate <NSObject>

- (void)menuItemChangedValue:(LeapMenuItem)menuItem;

@end

@interface LeapMenuView : NSView

- (void)setCursorPos:(NSPoint)cursorPos cursorObject:(id)cursorObject;

@property (nonatomic) id <LeapMenuDelegate> delegate;
@property (nonatomic) BOOL enableCursor;
@property (nonatomic) BOOL active;
@property (nonatomic) NSArray *cursorRects;

@end
