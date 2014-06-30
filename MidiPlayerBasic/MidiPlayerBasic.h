//
//  MidiPlayerBasic.h
//  MidiPlayerBasic
//
//  Created by Salvatore Avanzo on 29/06/14.
//  Copyright (c) 2014 Salvatore Avanzo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MidiPlayerBasic : NSObject

- (void) loadMIDIFile: (NSURL*) midiFileURL;

- (void) play;

- (void) stop;

@end
