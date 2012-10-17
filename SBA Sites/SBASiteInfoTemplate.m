//
//  SBASiteInfoTemplate.m
//  SBA Sites
//
//  Created by Ross Chapman on 10/12/12.
//
//

#import "SBASiteInfoTemplate.h"

#define FONT_SIZE 15.0f
#define VIEW_CONTENT_MARGIN 30.0f

@implementation SBASiteInfoTemplate

//Only implement if you want to entirely customize the callout
- (UIView *)customViewForGraphic:(AGSGraphic *) graphic screenPoint:(CGPoint) screen mapPoint:(AGSPoint *) mapPoint {
	//create a view programatically, or load from nib file
	
	//get the site code & name
	NSString *siteCode = [graphic.attributes objectForKey:@"SiteCode"];
	NSString *siteName = [graphic.attributes objectForKey:@"SiteName"];
	
	[[NSBundle mainBundle] loadNibNamed:@"SBASiteInfoTemplateView" owner:self options:nil];
	
	self.title.text = siteCode;
	self.subtitle.text = siteName;
	
	CGFloat viewWidth = [self widthForViewWithFontSize:FONT_SIZE andMargin:VIEW_CONTENT_MARGIN];
	
	self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, viewWidth, self.view.frame.size.height);
	self.title.frame = CGRectMake(self.title.frame.origin.x, self.title.frame.origin.y, self.view.frame.size.width - 2 * VIEW_CONTENT_MARGIN, self.title.frame.size.height);
	self.subtitle.frame = CGRectMake(self.subtitle.frame.origin.x, self.subtitle.frame.origin.y, self.view.frame.size.width - 2 * VIEW_CONTENT_MARGIN, self.subtitle.frame.size.height);
	NSLog(@"%@", NSStringFromCGRect(self.view.frame));
	
	
	return self.view;
}

- (CGFloat)widthForViewWithFontSize:(CGFloat)size andMargin:(CGFloat)margin
{
	CGFloat titleWidth = [self widthForLabel:self.title withFontSize:size];
	CGFloat subtitleWidth = [self widthForLabel:self.subtitle withFontSize:size];
	return MAX(MAX(titleWidth, subtitleWidth), 70.0f) + margin * 2;
}

- (CGFloat)widthForLabel:(UILabel *)label withFontSize:(CGFloat)size
{
	CGSize constraint = CGSizeMake(240.0f, 21.0f);
	CGSize labelSize = [label.text sizeWithFont:[UIFont systemFontOfSize:size] constrainedToSize:constraint lineBreakMode:NSLineBreakByTruncatingTail];
	return labelSize.width;
}

@end
