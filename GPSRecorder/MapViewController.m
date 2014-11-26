//
//  MapViewController.m
//  GPSRecorder
//
//  Created by zhangchao on 14/11/14.
//  Copyright (c) 2014年 zhangchao. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    NSLog(@"viewDidLoad isRealTimeMode : %d", _isRealTimeMode);
    _mTrackMapView.delegate = self;
    if (_isRealTimeMode) {
        _mTrackMapView.showsUserLocation = YES;
        _mTrackMapView.userTrackingMode = MKUserTrackingModeFollow;
    }
    [_mTrackMapView setMapType:MKMapTypeStandard];
    [_mTrackMapView setZoomEnabled:YES];

    _countOfPoints = 0;
    _currentTrackPoints = [NSMutableArray array];

    if (_gpxData != nil) {
        _gpxParser = [[GPXParser alloc] initWithData:_gpxData];
        _gpxParser.delegate = self;
        _gpxParser.callbackMode = PARSER_CALLBACK_MODE_JUST_RESULT;
        [_gpxParser parserAllElements];
    }
}

- (void)dealloc {
    NSLog(@"MapViewController dealloc");
    [_gpxParser stopParser];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)theMapView didUpdateUserLocation:(MKUserLocation *)userLocation{
//    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 1000, 1000);
//    [_mTrackMapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
//    [_mTrackMapView setRegion:[_mTrackMapView regionThatFits:region] animated:YES];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay {
    MKOverlayView *overlayView = nil;
    if (overlay == _routeLine) {
        //if we have not yet created an overlay view for this overlay, create it now.
        if (nil == _routeLineView) {
            _routeLineView = [[MKPolylineView alloc] initWithPolyline:_routeLine];
            _routeLineView.fillColor = [UIColor redColor];
            _routeLineView.strokeColor = [UIColor redColor];
            _routeLineView.lineWidth = 3;
        }
        overlayView = _routeLineView;
    }

    return overlayView;
}

#pragma mark - GPXParser

- (void)rootCreatorDidParser:(NSString *)creator {
    NSLog(@"rootCreatorDidParser from GPXParserDelegate. %@", creator);
}

- (void)rootVersionDidParser:(NSString *)version {
    NSLog(@"rootVersionDidParser from GPXParserDelegate. %@", version);
}

- (void)onErrorWhenParser:(int)errorCode {
    NSLog(@"onErrorWhenParser from GPXParserDelegate, errorCode : %d", errorCode);
}

- (void)onPercentageOfParser:(double)percentage {
    NSLog(@"onPercentOfParser from GPXParserDelegate, percentage : %f", percentage);
}

- (void)trackPointDidParser:(TrackPoint *)trackPoint {
}

- (void)trackSegmentDidParser:(TrackSegment *)segment {
}

- (void)trackDidParser:(Track *)track {
}

- (void)allTracksDidParser:(NSArray *)tracks {
    _countOfPoints = 0;
    for (Track *track in tracks) {
        _countOfPoints += track.countOfPoints;
        for (TrackSegment *segment in [track trackSegments]) {
            for (TrackPoint *point in [segment trackPoints]) {
                [_currentTrackPoints addObject:point];
            }
        }
    }

    // create a c array of points.
    MKMapPoint *pointArray = malloc(sizeof(CLLocationCoordinate2D) * _countOfPoints);
    for (int i = 0; i < _countOfPoints; i++) {
        TrackPoint *trackPoint = [_currentTrackPoints objectAtIndex:i];
        CLLocation *location = trackPoint.location;
        CLLocationCoordinate2D coord = location.coordinate;
        MKMapPoint mapPoint = MKMapPointForCoordinate(coord);
        pointArray[i] = mapPoint;
    }

    _routeLine = [MKPolyline polylineWithPoints:pointArray count:_countOfPoints];
    [_mTrackMapView addOverlay:_routeLine];
}


@end
