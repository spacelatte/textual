/* ********************************************************************* 
       _____        _               _    ___ ____   ____
      |_   _|___  _| |_ _   _  __ _| |  |_ _|  _ \ / ___|
       | |/ _ \ \/ / __| | | |/ _` | |   | || |_) | |
       | |  __/>  <| |_| |_| | (_| | |   | ||  _ <| |___
       |_|\___/_/\_\\__|\__,_|\__,_|_|  |___|_| \_\\____|

 Copyright (c) 2010 — 2014 Codeux Software & respective contributors.
     Please see Acknowledgements.pdf for additional information.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Textual IRC Client & Codeux Software nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 SUCH DAMAGE.

 *********************************************************************** */

#import "TextualApplication.h"

@implementation TVCServerList

#pragma mark -
#pragma mark Additions/Removal

- (void)addItemToList:(NSInteger)index inParent:(id)parent
{
	NSAssertReturn(index >= 0);

	[self insertItemsAtIndexes:[NSIndexSet indexSetWithIndex:index]
					  inParent:parent
				 withAnimation:(NSTableViewAnimationEffectFade | NSTableViewAnimationSlideRight)];

	if (parent) {
		[self reloadItem:parent];
	}
}

- (void)removeItemFromList:(id)oldObject
{
	/* Get the row. */
	NSInteger rowIndex = [self rowForItem:oldObject];

	NSAssertReturn(rowIndex >= 0);

	/* Do we have a parent? */
	id parentItem = [self parentForItem:oldObject];

	if ([parentItem isKindOfClass:[IRCClient class]]) {
		/* We have a parent, get the index of the child. */
		NSArray *childrenItems = [self rowsFromParentGroup:parentItem];

		rowIndex = [childrenItems indexOfObject:oldObject];
	} else {
		/* We are the parent. Get our own index. */
		NSArray *groupItems = [self groupItems];
		
		rowIndex = [groupItems indexOfObject:oldObject];
	}

	/* Remove object. */
	NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:rowIndex];

	[self removeItemsAtIndexes:indexSet
					  inParent:parentItem
				 withAnimation:(NSTableViewAnimationEffectFade | NSTableViewAnimationSlideLeft)];

	if (parentItem) {
		[self reloadItem:parentItem];
	}
}

#pragma mark -
#pragma mark Drawing Updates

- (void)reloadAllDrawings:(BOOL)doNotLimit
{
}

- (void)reloadAllDrawings
{
}

- (void)reloadAllDrawingsIgnoringOtherReloads
{
}

- (void)updateDrawingForItem:(IRCTreeItem *)cellItem
{
}

- (void)updateDrawingForItem:(IRCTreeItem *)cellItem skipDrawingCheck:(BOOL)doNotLimit
{
}

- (void)updateDrawingForRow:(NSInteger)rowIndex
{
}

- (void)updateDrawingForRow:(NSInteger)rowIndex skipDrawingCheck:(BOOL)doNotLimit
{
}

- (void)updateBackgroundColor
{
}

- (BOOL)allowsVibrancy
{
	return NO;
}

- (NSScrollView *)scrollView
{
	return [self enclosingScrollView];
}

#pragma mark -
#pragma mark Events

- (NSMenu *)menuForEvent:(NSEvent *)e
{
	NSPoint p = [self convertPoint:[e locationInWindow] fromView:nil];

	NSInteger i = [self rowAtPoint:p];

	if (i >= 0 && NSDissimilarObjects(i, [self selectedRow])) {
		[self selectItemAtIndex:i];
	} else if (i == -1) {
		return [menuController() addServerMenu];
	}

	return [self menu];
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
	TVCMainWindowNegateActionWithAttachedSheet();
	
	[super rightMouseDown:theEvent];
}

- (void)keyDown:(NSEvent *)e
{
	if (self.keyDelegate) {
		switch ([e keyCode]) {
			case 123 ... 126:
			case 116:
			case 121:
			{
				break;
			}
			default:
			{
				if ([self.keyDelegate respondsToSelector:@selector(serverListKeyDown:)]) {
					[self.keyDelegate serverListKeyDown:e];
				}
				
				break;
			}
		}
	}
}

#pragma mark -
#pragma mark User Interface Design Elements

- (NSColor *)properBackgroundColor
{
	if ([mainWindow() isInactive] == NO) {
		return [self activeWindowListBackgroundColor];
	} else {
		return [self inactiveWindowListBackgroundColor];
	}
}

- (NSColor *)activeWindowListBackgroundColor
{
	return [TXUserInterface defineUserInterfaceItem:[NSColor sourceListBackgroundColor]
									   invertedItem:[NSColor internalCalibratedRed:38.0 green:38.0 blue:38.0 alpha:1.0]];
}

- (NSColor *)inactiveWindowListBackgroundColor
{
	return [TXUserInterface defineUserInterfaceItem:[NSColor internalCalibratedRed:237.0 green:237.0 blue:237.0 alpha:1.0]
									   invertedItem:[NSColor internalCalibratedRed:38.0 green:38.0 blue:38.0 alpha:1.0]];
}

- (NSFont *)messageCountBadgeFont
{
	return [RZFontManager() fontWithFamily:@"Helvetica" traits:NSBoldFontMask weight:15 size:10.5];
}

- (NSFont *)serverCellFont
{
	return [NSFont fontWithName:@"LucidaGrande-Bold" size:12.0];
}

- (NSFont *)normalChannelCellFont
{
	if ([TPCPreferences useLargeFontForSidebars]) {
		return [NSFont fontWithName:@"LucidaGrande" size:12.0];
	} else {
		return [NSFont fontWithName:@"LucidaGrande" size:11.0];
	}
}

- (NSFont *)selectedChannelCellFont
{
	if ([TPCPreferences useLargeFontForSidebars]) {
		return [NSFont fontWithName:@"LucidaGrande-Bold" size:12.0];
	} else {
		return [NSFont fontWithName:@"LucidaGrande-Bold" size:11.0];
	}
}

- (NSInteger)channelCellTextFieldLeftMargin
{
	/* Keep this in sync with the interface builder file. */
	
	return 38.0;
}

- (NSInteger)serverCellTextFieldLeftMargin
{
	/* Keep this in sync with the interface builder file. */
	
	return 16.0;
}

- (NSInteger)serverCellTextFieldRightMargin
{
	return 5.0;
}

- (NSInteger)messageCountBadgeHeight
{
	return 14.0;
}

- (NSInteger)messageCountBadgePadding
{
	return 5.0;
}

- (NSInteger)messageCountBadgeMinimumWidth
{
	return 22.0;
}

- (NSInteger)messageCountBadgeRightMargin
{
	return 5.0;
}

- (NSColor *)messageCountBadgeHighlightBackgroundColor
{
	return [TXUserInterface defineUserInterfaceItem:[NSColor internalCalibratedRed:210 green:15 blue:15 alpha:1.0]
									   invertedItem:[NSColor internalCalibratedRed:141.0 green:0.0 blue:0.0  alpha:1.0]];
}

- (NSColor *)messageCountBadgeAquaBackgroundColor
{
	return [TXUserInterface defineUserInterfaceItem:[NSColor internalCalibratedRed:152 green:168 blue:202 alpha:1.0]
									   invertedItem:[NSColor internalCalibratedRed:48.0 green:48.0 blue:48.0 alpha:1.0]];
}

- (NSColor *)messageCountBadgeGraphtieBackgroundColor
{
	return [TXUserInterface defineUserInterfaceItem:[NSColor internalCalibratedRed:132 green:147 blue:163 alpha:1.0]
									   invertedItem:[NSColor internalCalibratedRed:48.0 green:48.0 blue:48.0 alpha:1.0]];
}

- (NSColor *)messageCountBadgeSelectedBackgroundColor
{
	return [TXUserInterface defineUserInterfaceItem:[NSColor whiteColor]
									   invertedItem:[NSColor darkGrayColor]];
}

- (NSColor *)messageCountBadgeShadowColor
{
	return [TXUserInterface defineUserInterfaceItem:[NSColor colorWithCalibratedWhite:1.00 alpha:0.60]
									   invertedItem:[NSColor internalCalibratedRed:60.0 green:60.0 blue:60.0 alpha:1.0]];
}

- (NSColor *)messageCountBadgeNormalTextColor
{
	return [NSColor whiteColor];
}

- (NSColor *)messageCountBadgeSelectedTextColor
{
	return [TXUserInterface defineUserInterfaceItem:[NSColor internalCalibratedRed:158 green:169 blue:197 alpha:1.0]
									   invertedItem:[NSColor whiteColor]];
}

- (NSColor *)serverCellNormalTextColor
{
	return [TXUserInterface defineUserInterfaceItem:[NSColor outlineViewHeaderTextColor]
									   invertedItem:[NSColor internalCalibratedRed:225.0 green:224.0 blue:224.0 alpha:1.0]];
}

- (NSColor *)serverCellDisabledTextColor
{
	return [TXUserInterface defineUserInterfaceItem:[NSColor outlineViewHeaderDisabledTextColor]
									   invertedItem:[NSColor internalCalibratedRed:169.0 green:169.0 blue:169.0 alpha:1.0]];
}

- (NSColor *)serverCellSelectedTextColorForActiveWindow
{
	return [TXUserInterface defineUserInterfaceItem:[NSColor whiteColor]
									   invertedItem:[NSColor internalCalibratedRed:36.0 green:36.0 blue:36.0 alpha:1.0]];
}

- (NSColor *)serverCellSelectedTextColorForInactiveWindow
{
	return [TXUserInterface defineUserInterfaceItem:[NSColor whiteColor]
									   invertedItem:[NSColor internalCalibratedRed:36.0 green:36.0 blue:36.0 alpha:1.0]];
}

- (NSColor *)serverCellNormalTextShadowColorForActiveWindow
{
	return [TXUserInterface defineUserInterfaceItem:[NSColor colorWithCalibratedWhite:1.00 alpha:1.00]
									   invertedItem:[NSColor colorWithCalibratedWhite:0.00 alpha:0.90]];
}

- (NSColor *)serverCellNormalTextShadowColorForInactiveWindow
{
	return [TXUserInterface defineUserInterfaceItem:[NSColor colorWithCalibratedWhite:1.00 alpha:1.00]
									   invertedItem:[NSColor colorWithCalibratedWhite:0.00 alpha:0.90]];
}

- (NSColor *)serverCellSelectedTextShadowColorForActiveWindow
{
	return [TXUserInterface defineUserInterfaceItem:[NSColor colorWithCalibratedWhite:0.00 alpha:0.30]
									   invertedItem:[NSColor colorWithCalibratedWhite:1.00 alpha:0.30]];
}

- (NSColor *)serverCellSelectedTextShadowColorForInactiveWindow
{
	return [TXUserInterface defineUserInterfaceItem:[NSColor colorWithCalibratedWhite:0.00 alpha:0.20]
									   invertedItem:[NSColor colorWithCalibratedWhite:1.00 alpha:0.30]];
}

- (NSColor *)channelCellNormalTextColor
{
	return [TXUserInterface defineUserInterfaceItem:[NSColor blackColor]
									   invertedItem:[NSColor internalCalibratedRed:225.0 green:224.0 blue:224.0 alpha:1.0]];
}

- (NSColor *)channelCellDisabledItemTextColor
{
	return [TXUserInterface defineUserInterfaceItem:[NSColor internalCalibratedRed:0.0 green:0.0 blue:0.0 alpha:0.6]
									   invertedItem:[NSColor internalCalibratedRed:225.0 green:224.0 blue:224.0 alpha:0.6]];
}

- (NSColor *)channelCellSelectedTextColorForActiveWindow
{
	return [TXUserInterface defineUserInterfaceItem:[NSColor whiteColor]
									   invertedItem:[NSColor internalCalibratedRed:36.0 green:36.0 blue:36.0 alpha:1.0]];
}

- (NSColor *)channelCellSelectedTextColorForInactiveWindow
{
	return [TXUserInterface defineUserInterfaceItem:[NSColor whiteColor]
									   invertedItem:[NSColor internalCalibratedRed:36.0 green:36.0 blue:36.0 alpha:1.0]];
}

- (NSColor *)channelCellNormalTextShadowColor
{
	return [TXUserInterface defineUserInterfaceItem:[NSColor colorWithSRGBRed:1.0 green:1.0 blue:1.0 alpha:0.6]
									   invertedItem:[NSColor colorWithCalibratedWhite:0.00 alpha:0.90]];
}

- (NSColor *)channelCellSelectedTextShadowColorForActiveWindow
{
	return [TXUserInterface defineUserInterfaceItem:[NSColor colorWithCalibratedWhite:0.00 alpha:0.48]
									   invertedItem:[NSColor colorWithCalibratedWhite:1.00 alpha:0.30]];
}

- (NSColor *)channelCellSelectedTextShadowColorForInactiveWindow
{
	return [TXUserInterface defineUserInterfaceItem:[NSColor colorWithCalibratedWhite:0.00 alpha:0.30]
									   invertedItem:[NSColor colorWithCalibratedWhite:1.00 alpha:0.30]];
}

- (NSColor *)graphiteTextSelectionShadowColor
{
	return [NSColor internalCalibratedRed:17 green:73 blue:126 alpha:1.00];
}

#pragma mark -
#pragma mark Utilities

- (NSImage *)disclosureTriangleInContext:(BOOL)up selected:(BOOL)selected
{
	BOOL invertedColors = [TPCPreferences invertSidebarColors];
	
	if (invertedColors) {
		if (up) {
			if (selected) {
				return [NSImage imageNamed:@"DarkServerListViewDisclosureUpSelected"];
			} else {
				return [NSImage imageNamed:@"DarkServerListViewDisclosureUp"];
			}
		} else {
			if (selected) {
				return [NSImage imageNamed:@"DarkServerListViewDisclosureDownSelected"];
			} else {
				return [NSImage imageNamed:@"DarkServerListViewDisclosureDown"];
			}
		}
	} else {
		if (up) {
			return self.defaultDisclosureTriangle;
		} else {
			return self.alternateDisclosureTriangle;
		}
	}
}

- (NSString *)privateMessageStatusIconFilename:(BOOL)selected
{
	return [TXUserInterface defineUserInterfaceItem:@"NSUser" invertedItem:@"DarkServerListViewSelectedPrivateMessageUser" withOperator:(selected == NO)];
}

@end
