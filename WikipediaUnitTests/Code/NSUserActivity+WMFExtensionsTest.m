#import <XCTest/XCTest.h>
#import "NSUserActivity+WMFExtensions.h"


@interface NSUserActivity_WMFExtensions_wmf_activityForWikipediaScheme_Test : XCTestCase
@end

@implementation NSUserActivity_WMFExtensions_wmf_activityForWikipediaScheme_Test

- (void)testURLWithoutWikipediaSchemeReturnsNil {
    NSURL *url = [NSURL URLWithString:@"http://www.foo.com"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertNil(activity);
}

- (void)testInvalidArticleURLReturnsNil {
    NSURL *url = [NSURL URLWithString:@"wikipedia://en.wikipedia.org/Foo"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertNil(activity);
}

- (void)testArticleURL {
    NSURL *url = [NSURL URLWithString:@"wikipedia://en.wikipedia.org/wiki/Foo"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertEqual(activity.wmf_type, WMFUserActivityTypeLink);
    XCTAssertEqualObjects(activity.webpageURL.absoluteString, @"https://en.wikipedia.org/wiki/Foo");
}

- (void)testExploreURL {
    NSURL *url = [NSURL URLWithString:@"wikipedia://explore"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertEqual(activity.wmf_type, WMFUserActivityTypeExplore);
}

- (void)testHistoryURL {
    NSURL *url = [NSURL URLWithString:@"wikipedia://history"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertEqual(activity.wmf_type, WMFUserActivityTypeHistory);
}

- (void)testSavedURL {
    NSURL *url = [NSURL URLWithString:@"wikipedia://saved"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertEqual(activity.wmf_type, WMFUserActivityTypeSavedPages);
}

- (void)testSearchURL {
    NSURL *url = [NSURL URLWithString:@"wikipedia://en.wikipedia.org/w/index.php?search=dog"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertEqual(activity.wmf_type, WMFUserActivityTypeLink);
    XCTAssertEqualObjects(activity.webpageURL.absoluteString,
                          @"https://en.wikipedia.org/w/index.php?search=dog&title=Special:Search&fulltext=1");
}

// Good case - Places with coordinates
- (void)testPlacesURLWithCustomSchemeAndCoordinates {
    NSURL *url = [NSURL URLWithString:@"abnamro-test://places?lat=52.3547498&lon=4.8339215"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    
    XCTAssertEqual(activity.wmf_type, WMFUserActivityTypePlaces);
    XCTAssertEqualObjects(activity.userInfo[@"WMFPlacesLatitude"], @"52.3547498");
    XCTAssertEqualObjects(activity.userInfo[@"WMFPlacesLongitude"], @"4.8339215");
}

// Good case - Places without coordinates (still valid)
- (void)testPlacesURLWithCustomSchemeWithoutCoordinates {
    NSURL *url = [NSURL URLWithString:@"abnamro-test://places"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    
    XCTAssertEqual(activity.wmf_type, WMFUserActivityTypePlaces);
    XCTAssertNil(activity.userInfo[@"WMFPlacesLatitude"]);
    XCTAssertNil(activity.userInfo[@"WMFPlacesLongitude"]);
}

// Bad case - Only latitude (incomplete)
- (void)testPlacesURLWithOnlyLatitudeIgnoresCoordinate {
    NSURL *url = [NSURL URLWithString:@"abnamro-test://places?lat=52.3547498"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    
    XCTAssertEqual(activity.wmf_type, WMFUserActivityTypePlaces);
    // Should not store partial coordinates
    XCTAssertNil(activity.userInfo[@"WMFPlacesLatitude"]);
    XCTAssertNil(activity.userInfo[@"WMFPlacesLongitude"]);
}

// Bad case - Custom scheme with wrong host
- (void)testCustomSchemeWithExploreReturnsNil {
    NSURL *url = [NSURL URLWithString:@"abnamro-test://explore"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertNil(activity);
}


@end

