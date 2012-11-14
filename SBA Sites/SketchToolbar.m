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


#import "SketchToolbar.h"

@interface SketchToolbar ()

@end


@implementation SketchToolbar

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_undoTool removeTarget:self action:@selector(undo) forControlEvents:UIControlEventTouchUpInside];
	[_redoTool removeTarget:self action:@selector(redo) forControlEvents:UIControlEventTouchUpInside];
	[_saveTool removeTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
	[_clearTool removeTarget:self action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
}

- (id)initWithToolbar:(UIToolbar*)toolbar sketchLayer:(AGSSketchGraphicsLayer*)sketchLayer mapView:(AGSMapView*) mapView graphicsLayer:(AGSGraphicsLayer*)graphicsLayer andLabel:(UILabel *)label
{
	
    self = [super init];
    if (self) {
		
		//hold references to the mapView, graphicsLayer, and sketchLayer
		_sketchLayer = sketchLayer;
		_mapView = mapView;
		_graphicsLayer = graphicsLayer;
		_distanceLabel = label;
		
		//sketch layer should begin tracking touch events to sketch a polyline
		_mapView.touchDelegate = _sketchLayer;
		_sketchLayer.geometry = [[AGSMutablePolyline alloc] initWithSpatialReference:_mapView.spatialReference];
		_sketchLayer.midVertexSymbol = nil;
		
		//Get references to the UI elements in the toolbar
		//Each UI element was assigned a "tag" in the nib file to make it easy to find them
		_undoTool = (UIButton*) [toolbar viewWithTag:56];
		_redoTool = (UIButton*) [toolbar viewWithTag:57];
		_saveTool = (UIButton*) [toolbar viewWithTag:58];
		_clearTool = (UIButton*) [toolbar viewWithTag:59];
		
		[_undoTool addTarget:self action:@selector(undo) forControlEvents:UIControlEventTouchUpInside];
		[_redoTool addTarget:self action:@selector(redo) forControlEvents:UIControlEventTouchUpInside];
		[_saveTool addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
		[_clearTool addTarget:self action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
		
		//Register for "Geometry Changed" notifications
		//We want to enable/disable UI elements when sketch geometry is modified
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToGeomChanged:) name:@"GeometryChanged" object:nil];
    }
    return self;
}

- (void)respondToGeomChanged: (NSNotification*) notification {
	//Enable/disable UI elements appropriately
	_undoTool.enabled = [_sketchLayer.undoManager canUndo];
	_redoTool.enabled = [_sketchLayer.undoManager canRedo];
	_clearTool.enabled = ![_sketchLayer.geometry isEmpty] && _sketchLayer.geometry!=nil;
	_saveTool.enabled = [_sketchLayer.geometry isValid];
	
	AGSGeometryEngine *geometryEngine = [AGSGeometryEngine defaultGeometryEngine];
	AGSGeometry *sketchGeometry = [_sketchLayer geometry];
	double length = [geometryEngine geodesicLengthOfGeometry:sketchGeometry inUnit:AGSSRUnitSurveyMile];
	NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:3];
	
	_distanceLabel.text = [NSString stringWithFormat:@"%@ miles", [formatter stringFromNumber:@(length)]];
	
}
- (IBAction) undo {
	if([_sketchLayer.undoManager canUndo]) //extra check, just to be sure
		[_sketchLayer.undoManager undo];
}
- (IBAction) redo {
	if([_sketchLayer.undoManager canRedo]) //extra check, just to be sure
		[_sketchLayer.undoManager redo];
}
- (IBAction) clear {
	[_sketchLayer clear];
}
- (IBAction) save {
	//Get the sketch geometry
	AGSGeometry* sketchGeometry = [_sketchLayer.geometry copy];
	
	//If this is not a new sketch (i.e we are modifying an existing graphic)
	if(_activeGraphic!=nil){
		//Modify the existing graphic giving it the new geometry
		_activeGraphic.geometry = sketchGeometry;
		_activeGraphic = nil;
		
	}else {
		//Add a new graphic to the graphics layer
		AGSGraphic* graphic = [AGSGraphic graphicWithGeometry:sketchGeometry symbol:nil attributes:nil infoTemplateDelegate:nil];
		[_graphicsLayer addGraphic:graphic];
	}
	
	[_graphicsLayer dataChanged];
	[_sketchLayer clear];
	[_sketchLayer.undoManager removeAllActions];
}

- (void) mapView:(AGSMapView*)mapView
 didClickAtPoint:(CGPoint)screen
		mapPoint:(AGSPoint*)mappoint
		graphics:(NSDictionary*)graphics {
	//find which graphic to modify
	NSEnumerator *enumerator = [graphics objectEnumerator];
	NSArray* graphicArray = (NSArray*) [enumerator nextObject];
	if(graphicArray!=nil && [graphicArray count]>0){
		//Get the graphic's geometry to the sketch layer so that it can be modified
		_activeGraphic = (AGSGraphic*)[graphicArray objectAtIndex:0];
		AGSGeometry* geom = [_activeGraphic.geometry mutableCopy];
		
		//Feed the graphic's geometry to the sketch layer so that user can modify it
		_sketchLayer.geometry = geom;
		
		//sketch layer should begin tracking touch events to modify the sketch
		_mapView.touchDelegate = _sketchLayer;
	}
}


@end
