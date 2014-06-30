//
//  MidiPlayerBasic.m
//  MidiPlayerBasic
//
//  Created by Salvatore Avanzo on 29/06/14.
//  Copyright (c) 2014 Salvatore Avanzo. All rights reserved.
//

#import "MidiPlayerBasic.h"

#import <AudioToolbox/AudioToolbox.h>

@interface MidiPlayerBasic ()

@property (nonatomic) MusicPlayer musicPlayer;
@property (nonatomic) MusicSequence musicSequence;

@end

@implementation MidiPlayerBasic

@synthesize musicPlayer = _musicPlayer;
@synthesize musicSequence = _musicSequence;


-(id)init {
    if ( self = [super init] ) {
        OSStatus status = NewMusicPlayer(&_musicPlayer);
        NSLog(@"Music Player created (%d)", (int)status);
        
        status = NewMusicSequence(&_musicSequence);
        NSLog(@"Music Sequence created (%d)", (int)status);
        
        status = MusicPlayerSetSequence(_musicPlayer,
                                                 _musicSequence);
        NSLog(@"Association created (%d)", (int)status);
    }
    return self;
}

- (void)dealloc
{
    DisposeMusicPlayer(self.musicPlayer);

    DisposeMusicSequence(self.musicSequence);
}

- (void) loadMIDIFile: (NSURL*) midiFileURL
{
    OSStatus status = MusicSequenceFileLoad(self.musicSequence,
                                     (__bridge CFURLRef) midiFileURL,
                                     0, // can be zero in many cases
                                     kMusicSequenceLoadSMF_ChannelsToTracks);
    
    NSLog(@"File loaded (%d)", (int)status);

    status = MusicPlayerPreroll(self.musicPlayer);
    
    NSLog(@"Preroll (%d)", (int)status);
}

- (void) play
{
    OSStatus status = MusicPlayerStart(self.musicPlayer);
    NSLog(@"Play (%d)", (int)status);
}

- (void) stop
{
    OSStatus status = MusicPlayerStop(self.musicPlayer);
    NSLog(@"Stop (%d)", (int)status);
}

@end