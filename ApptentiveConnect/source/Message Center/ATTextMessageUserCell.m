//
//  ATTextMessageUserCell.m
//  ApptentiveConnect
//
//  Created by Andrew Wooster on 10/9/12.
//  Copyright (c) 2012 Apptentive, Inc. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "ATTextMessageUserCell.h"
#import "ATUtilities.h"

@interface ATTextMessageUserCell ()

@property (assign, nonatomic) CGFloat horizontalCellPadding;

@end

@implementation ATTextMessageUserCell

- (void)setup {
	self.horizontalCellPadding = CGRectGetWidth(self.bounds) - CGRectGetWidth(self.messageText.bounds);
	
	self.messageText.delegate = self;
	NSTextCheckingType types = NSTextCheckingTypeLink;
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]]) {
		types |= NSTextCheckingTypePhoneNumber;
	}
	if ([ATUtilities osVersionGreaterThanOrEqualTo:@"5"]) {
		self.messageText.enabledTextCheckingTypes = types;
	}
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		[self setup];
	}
	return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	[self setup];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];

	// Configure the view for the selected state
}

- (void)setComposing:(BOOL)comp {
	if (_composing != comp) {
		_composing = comp;
		if (_composing) {
			self.showDateLabel = NO;
		}
		[self setNeedsLayout];
	}
}

- (void)setShowDateLabel:(BOOL)show {
	if (_showDateLabel != show) {
		_showDateLabel = show;
		[self setNeedsLayout];
	}
}

- (void)setTooLong:(BOOL)isTooLong {
	if (_tooLong != isTooLong) {
		_tooLong = isTooLong;
		self.tooLongLabel.hidden = !_tooLong;
		ATLogDebug(@"setting too long to %d", _tooLong);
		if (_tooLong) {
			NSString *fullText = NSLocalizedString(@"Show full message.", @"Message bubble text for very long messages.");
			self.tooLongLabel.text = fullText;
		}
		[self setNeedsLayout];
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	if (self.showDateLabel == NO || self.composing) {
		self.dateLabel.hidden = YES;
		CGRect chatBubbleRect = self.chatBubbleContainer.frame;
		chatBubbleRect.size.height = self.bounds.size.height;
		chatBubbleRect.origin.y = 0;
		self.chatBubbleContainer.frame = chatBubbleRect;
	} else {
		self.dateLabel.hidden = NO;
		CGRect dateLabelRect = self.dateLabel.frame;
		CGRect chatBubbleRect = self.chatBubbleContainer.frame;
		chatBubbleRect.size.height = self.bounds.size.height - dateLabelRect.size.height;
		chatBubbleRect.origin.y = dateLabelRect.size.height;
		self.chatBubbleContainer.frame = chatBubbleRect;
	}
	self.chatBubbleContainer.hidden = self.composing;
	self.composingBubble.hidden = !self.composing;
}

- (void)dealloc {
	_messageText.delegate = nil;
}

- (CGFloat)cellHeightForWidth:(CGFloat)width {
	CGFloat cellHeight = 0;
	
	do { // once
		if (self.isComposing) {
			cellHeight += 60;
			break;
		}
		if (self.showDateLabel) {
			cellHeight += self.dateLabel.bounds.size.height;
		}
		cellHeight += self.usernameLabel.bounds.size.height;
		CGFloat textWidth = width - self.horizontalCellPadding;
		CGFloat heightPadding = 19 + 6;
		CGSize textSize = [self.messageText sizeThatFits:CGSizeMake(textWidth, CGFLOAT_MAX)];
		cellHeight += MAX(60, textSize.height + heightPadding);
	} while (NO);
	return cellHeight;
}

#pragma mark TTTAttributedLabelDelegate
- (void)attributedLabel:(ATTTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
	if ([[UIApplication sharedApplication] canOpenURL:url]) {
		[[UIApplication sharedApplication] openURL:url];
	}
}

- (void)attributedLabel:(TTTATTRIBUTEDLABEL_PREPEND(TTTAttributedLabel) *)label
didSelectLinkWithPhoneNumber:(NSString *)phoneNumber {
	NSString *phoneString = [NSString stringWithFormat:@"tel:%@", phoneNumber];
	NSURL *url = [NSURL URLWithString:phoneString];
	if ([[UIApplication sharedApplication] canOpenURL:url]) {
		[[UIApplication sharedApplication] openURL:url];
	}
}
@end
