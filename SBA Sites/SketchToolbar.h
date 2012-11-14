// Copyright 2012 ESRI
//
// All rights reserved under the copyright laws of the United States
// and applicable international laws, treaties, and conventions.
//
// You may freely redistribute and use this sample code, with or
// without modification, provided you include the original copyright
// notice and use restrictions.
//
// See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@interface SketchToolbar : NSObject <AGSMapViewTouchDelegate>{
	AGSSketchGraphicsLayer* _sketchLayer;
	AGSMapView* _mapView;
	AGSGraphicsLayer* _graphicsLayer;
	AGSGraphic* _activeGraphic;
	
	UIButton* _undoTool;
	UIButton* _redoTool;
	UIButton* _saveTool;
	UIButton* _clearTool;
	UILabel *_distanceLabel;
}

@property (nonatomic, strong) AGSGraphic* activeGraphic;
@property (nonatomic, strong) AGSSketchGraphicsLayer *sketchLayer;

- (id)initWithToolbar:(UIToolbar*)toolbar sketchLayer:(AGSSketchGraphicsLayer*)sketchLayer mapView:(AGSMapView*) mapView graphicsLayer:(AGSGraphicsLayer*)graphicsLayer andLabel:(UILabel *)label;

- (void) mapView:(AGSMapView*)mapView
 didClickAtPoint:(CGPoint)screen
		mapPoint:(AGSPoint*)mappoint
		graphics:(NSDictionary*)graphics ;	


@end
