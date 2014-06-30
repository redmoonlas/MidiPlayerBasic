//
//  ViewController.m
//  MidiPlayerBasic
//
//  Created by Salvatore Avanzo on 29/06/14.
//  Copyright (c) 2014 Salvatore Avanzo. All rights reserved.
//

#import "ViewController.h"
#import "MidiPlayerBasic.h"

@interface ViewController ()
            
@property (weak, nonatomic) IBOutlet UIButton *loadAndPlay;
@property (weak, nonatomic) IBOutlet UIButton *stopPlaying;

@property (strong, nonatomic) MidiPlayerBasic* midiPlayer;

@end

@implementation ViewController

- (MidiPlayerBasic*) midiPlayer {
    if (!_midiPlayer) {
        _midiPlayer = [[MidiPlayerBasic alloc] init];
    }
    return _midiPlayer;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.loadAndPlay addTarget:self action:@selector(loadAndPlayCmd:) forControlEvents:UIControlEventTouchDown];
    [self.stopPlaying addTarget:self action:@selector(stopPlayingCmd:) forControlEvents:UIControlEventTouchDown];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadAndPlayCmd:(UIButton*)sender {
    NSLog(@"Load and Play");
    
    NSURL *myMidiFile = [[NSBundle mainBundle]
                         URLForResource: @"dummy1" withExtension:@"mid"];
    
    [self.midiPlayer loadMIDIFile:myMidiFile];
    [self.midiPlayer play];
}

- (void) stopPlayingCmd:(UIButton *)sender {
    [self.midiPlayer stop];
}

@end
