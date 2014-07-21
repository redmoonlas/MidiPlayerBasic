//
//  MidiPlayerBasic.m
//  MidiPlayerBasic
//
//  Created by Salvatore Avanzo on 29/06/14.
//  Copyright (c) 2014 Salvatore Avanzo. All rights reserved.
//

#import "MidiPlayerBasic.h"

#import <AudioToolbox/AudioToolbox.h>

//__________________  CALLBACKs  __________________________





@interface MidiPlayerBasic ()



@property (nonatomic) MusicPlayer musicPlayer;
@property (nonatomic) MusicSequence musicSequence;

-(MIDIEndpointRef) setUpMusicSequenceWithMidiDestination;
-(void) setMidiDestination;

@end

@implementation MidiPlayerBasic

-(id)init {
    if ( self = [super init] ) {
        OSStatus status = NewMusicPlayer(&_musicPlayer);
        NSLog(@"Music Player created (%d)", (int)status);
    }
    return self;
}

- (void)dealloc
{
    DisposeMusicPlayer(self.musicPlayer);
}

- (void) loadMIDIFile: (NSURL*) midiFileURL
{
    NewMusicSequence(&_musicSequence);
    
    OSStatus status = MusicSequenceFileLoad(_musicSequence,
                                     (__bridge CFURLRef) midiFileURL,
                                     0, // can be zero in many cases
                                     kMusicSequenceLoadSMF_ChannelsToTracks);
    
    NSLog(@"File loaded (%d)", (int)status);
    
    // aggancia la musicSequence al MidiDestination & CallBack
    //MusicSequenceSetMIDIEndpoint(_musicSequence,
    
    [self  setMidiDestination];

    
    // Collega ila player alla musicSequence
    MusicPlayerSetSequence(self.musicPlayer, _musicSequence);

    status = MusicPlayerPreroll(self.musicPlayer);
    
    NSLog(@"Preroll (%d)", (int)status);
}

- (void) play
{
    OSStatus status = MusicPlayerStart(_musicPlayer);
    NSLog(@"Play (%d)", (int)status);
}

- (void) stop
{
    OSStatus status = MusicPlayerStop(self.musicPlayer);
    NSLog(@"Stop (%d)", (int)status);
    DisposeMusicSequence(self.musicSequence);
}

#pragma mark - Helper Methods


-(void) setMidiDestination{
    
    //   Create a MidiDestination  ++++++++++++++++++++++++++++
    
    MIDIClientRef   virtualMidi;
    MIDIClientCreate(CFSTR("VirtualClient"),
                                MyMIDINotifyProc,
                                (__bridge void *)(self),
                                &virtualMidi);
    
    
    
    MIDIEndpointRef virtualEndpoint;
    
     MIDIDestinationCreate(virtualMidi,
                                      (CFSTR("VirtualDestination")),
                                      MyMIDIReadProc,
                                      NULL,//self->_mySampler.samplerUnit,
                                      &virtualEndpoint);
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    // aggancia la musicSequence al virtualEndpoint
    MusicSequenceSetMIDIEndpoint(self.musicSequence,
                                            virtualEndpoint);
    
    
}



-(MIDIEndpointRef) setUpMusicSequenceWithMidiDestination{
    //+++++++   Crea la MidiDestination  ++++++++++++++++++++++++++++
    // Usare questa funzione ogni volta dopo aver caricato un nuovo midifile
    // e settato la musicSequence
    
    // Crea il virtuaMidi
    MIDIClientRef   virtualMidi;
    MIDIClientCreate(CFSTR("VirtualClient"),
                        MyMIDINotifyProc,
                        NULL,
                        &virtualMidi);
    
    // Crea il virtualEndpoint
    MIDIEndpointRef virtualEndpoint;
    MIDIDestinationCreate(virtualMidi,
                          (CFSTR("VirtualDestination")),
                          MyMIDIReadProc,
                          NULL,// --> da sostituire con AUGraph
                          &virtualEndpoint);
    
    
    MusicSequenceSetMIDIEndpoint(_musicSequence,virtualEndpoint);
    
    
    
    return virtualEndpoint;
}

#pragma mark - CALLBACKs
void MyMIDINotifyProc (const MIDINotification  *message, void *refCon) {
    printf("MIDI Notify, messageId=%d,", (int)message->messageID);
}

// Get the MIDI messages as they're sent
static void MyMIDIReadProc(const MIDIPacketList *pktlist,
                           void *refCon,
                           void *connRefCon) {
    
   //  NSLog(@"MyMIDIReadProc");
    
    // Cast our Sampler unit back to an audio unit
    AudioUnit *player = (AudioUnit*) refCon;
    
    
    MIDIPacket *packet = (MIDIPacket *)pktlist->packet;
    for (int i=0; i < pktlist->numPackets; i++) {
        Byte midiStatus = packet->data[0];
        Byte midiCommand = midiStatus >> 4;
        
        // If the command is note-on
        if (midiCommand == 0x09) {
            Byte note = packet->data[1] & 0x7F;
            Byte velocity = packet->data[2] & 0x7F;
            
            // Log the note letter in a readable format
            int noteNumber = ((int) note) % 12;
            NSString *noteType;
            switch (noteNumber) {
                case 0:
                    noteType = @"C";
                    break;
                case 1:
                    noteType = @"C#";
                    break;
                case 2:
                    noteType = @"D";
                    break;
                case 3:
                    noteType = @"D#";
                    break;
                case 4:
                    noteType = @"E";
                    break;
                case 5:
                    noteType = @"F";
                    break;
                case 6:
                    noteType = @"F#";
                    break;
                case 7:
                    noteType = @"G";
                    break;
                case 8:
                    noteType = @"G#";
                    break;
                case 9:
                    noteType = @"A";
                    break;
                case 10:
                    noteType = @"Bb";
                    break;
                case 11:
                    noteType = @"B";
                    break;
                default:
                    break;
            }
            //     NSLog([noteType stringByAppendingFormat:[NSString stringWithFormat:@": %i", noteNumber]]);
            
            NSLog(@"noteNumber %i = %@",noteNumber,noteType);
            
            // Use MusicDeviceMIDIEvent to send our MIDI message to the sampler to be played
            OSStatus result = noErr;
            
            result = MusicDeviceMIDIEvent ( player,     // AudioComponent  ???
                                           midiStatus,  // DATA[0]
                                           note,        // DATA[1]
                                           velocity,    // DATA[2]
                                           0);          // DATA[3] ??
            
        }
        packet = MIDIPacketNext(packet);
    }
}

@end