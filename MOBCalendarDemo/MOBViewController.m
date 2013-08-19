//
//  MOBViewController.m
//  MOBCalendarDemo
//
//  Created by Craig Stanford on 19/08/13.
//  Copyright (c) 2013 Craig Stanford. All rights reserved.
//

#import "MOBViewController.h"
#import <EventKit/EventKit.h>

#define kEventIdentifier @"MonsterBombTestEvent"

@interface MOBViewController ()

@property (nonatomic, strong) IBOutlet UILabel* eventDetailsLabel;
@property (nonatomic, strong) IBOutlet UIButton* createEventButton;
@property (nonatomic, strong) IBOutlet UIButton* addOneDayButton;
@property (nonatomic, strong) IBOutlet UIButton* addOneHourButton;
@property (nonatomic, strong) IBOutlet UIButton* subtractOneDayButton;
@property (nonatomic, strong) IBOutlet UIButton* subtractOneHourButton;

@property (nonatomic, strong) EKCalendar* calendar;
@property (nonatomic, strong) EKEventStore* eventStore;
@property (nonatomic, strong) EKEvent* event;

- (IBAction)createEventPressed:(id)sender;
- (IBAction)addOneDayPressed:(id)sender;
- (IBAction)addOneHourPressed:(id)sender;
- (IBAction)subtractOneDayPressed:(id)sender;
- (IBAction)subtractOneHourPressed:(id)sender;

@end

@implementation MOBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.eventStore = [[EKEventStore alloc] init];
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (granted) {
            self.event = [self.eventStore eventWithIdentifier:kEventIdentifier];
            [self updateEventLabel];
            [self updateButtons];
        } else {
            self.eventDetailsLabel.text = @"You must grant access to the Calendar to Create and Edit Events";
        }
    }];
    self.calendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:self.eventStore];
    for (EKSource* source in self.eventStore.sources) {
        if (source.sourceType == EKSourceTypeLocal) {
            self.calendar.source = source;
        }
    }
}

- (void)createEventPressed:(id)sender
{
    if (self.event) {
        NSError* error = nil;
        [self.eventStore removeEvent:self.event span:EKSpanThisEvent error:&error];
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"ERROR"
                                        message:@"There was a problem deleting the event"
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        } else {
            self.event = nil;
        }
    } else {
        self.event = [EKEvent eventWithEventStore:self.eventStore];
        self.event.calendar = self.calendar;
        self.event.startDate = [NSDate date];
        self.event.endDate = [NSDate dateWithTimeIntervalSinceNow:360];
        self.event.title = @"Important meeting";
        [self saveEvent];
    }
    [self updateEventLabel];
    [self updateButtons];
}

- (void)addOneDayPressed:(id)sender
{
    self.event.startDate = [self.event.startDate dateByAddingTimeInterval:86400];
    self.event.endDate = [self.event.endDate dateByAddingTimeInterval:86400];
    [self saveEvent];
}

- (void)addOneHourPressed:(id)sender
{
    self.event.startDate = [self.event.startDate dateByAddingTimeInterval:3600];
    self.event.endDate = [self.event.endDate dateByAddingTimeInterval:3600];
    [self saveEvent];
    
}

- (void)subtractOneDayPressed:(id)sender
{
    self.event.startDate = [self.event.startDate dateByAddingTimeInterval:-86400];
    self.event.endDate = [self.event.endDate dateByAddingTimeInterval:-86400];
    [self saveEvent];
}

- (void)subtractOneHourPressed:(id)sender
{
    self.event.startDate = [self.event.startDate dateByAddingTimeInterval:-3600];
    self.event.endDate = [self.event.endDate dateByAddingTimeInterval:-3600];
    [self saveEvent];
    
}

- (void)updateButtons
{
    BOOL enabled = NO;
    if (self.event) {
        [self.createEventButton setTitle:@"Delete Event" forState:UIControlStateNormal];
        enabled = YES;
    } else {
        [self.createEventButton setTitle:@"Create Event" forState:UIControlStateNormal];
        enabled = NO;
    }
    self.addOneDayButton.enabled = enabled;
    self.addOneHourButton.enabled = enabled;
    self.subtractOneDayButton.enabled = enabled;
    self.subtractOneHourButton.enabled = enabled;

}

- (void)updateEventLabel
{
    if (self.event) {
        self.eventDetailsLabel.text = [NSString stringWithFormat:@"\"%@\" at %@ (until %@)",
                                       self.event.title,
                                       [[[self class] dateFormatter] stringFromDate:self.event.startDate],
                                       [[[self class] dateFormatter] stringFromDate:self.event.endDate]];
    } else {
        self.eventDetailsLabel.text = @"No Event Exists";
    }
}

- (void)saveEvent
{
    NSError* error = nil;
    [self.eventStore saveEvent:self.event span:EKSpanThisEvent error:&error];
    if (error) {
        self.event = nil;
        [[[UIAlertView alloc] initWithTitle:@"ERROR"
                                    message:@"There was a problem saving the event"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        
    } else {
        [self updateEventLabel];
        [self updateButtons];
    }
}

+ (NSDateFormatter*)dateFormatter
{
    static NSDateFormatter* formatter;
    if (!formatter) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"HH:mm 'on' dd/MM/yyyy"];
        });
    }
    return formatter;
}

@end
