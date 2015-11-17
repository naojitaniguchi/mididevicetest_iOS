//
//  ViewController.m
//  mididevicetest
//
//  Created by 谷口 直嗣 on 2015/11/15.
//  Copyright © 2015年 谷口 直嗣. All rights reserved.
//

#import "ViewController.h"
#import <CoreMIDI/CoreMIDI.h>


NSString *getName(MIDIObjectRef object)
{
    // Returns the name of a given MIDIObjectRef as an NSString
    CFStringRef name = nil;
    if (noErr != MIDIObjectGetStringProperty(object, kMIDIPropertyName, &name))
        return nil;
    return (NSString *)CFBridgingRelease(name);
}

NSString *getPropatyString(MIDIObjectRef object, CFStringRef property )
{
    //kMIDIPropertyManufacturer
    //kMIDIPropertyModel
    //kMIDIPropertyUniqueID
    //kMIDIPropertyDeviceID
    // kMIDIPropertyDisplayName
    
    // Returns the name of a given MIDIObjectRef as an NSString
    CFStringRef name = nil;
    if (noErr != MIDIObjectGetStringProperty(object, property, &name))
        return nil;
    return (NSString *)CFBridgingRelease(name);
}

void getMidiDevices(){
    // How many MIDI devices do we have?
    ItemCount deviceCount = MIDIGetNumberOfDevices();
    
    NSLog(@"deviceCount: %lu", deviceCount);
    
    // Iterate through all MIDI devices
    for (ItemCount i = 0 ; i < deviceCount ; ++i) {
        
        // Grab a reference to current device
        MIDIDeviceRef device = MIDIGetDevice(i);
        NSLog(@"Device: %@", getName(device));
        NSLog(@"Device Manufacturer: %@", getPropatyString(device, kMIDIPropertyManufacturer ));
        NSLog(@"Device Model: %@", getPropatyString(device, kMIDIPropertyModel ));
        NSLog(@"Device UniqueID: %@", getPropatyString(device, kMIDIPropertyUniqueID ));
        NSLog(@"Device DeviceID: %@", getPropatyString(device, kMIDIPropertyDeviceID ));
        NSLog(@"Device DisplayName: %@", getPropatyString(device, kMIDIPropertyDisplayName ));
        
        
        // Is this device online? (Currently connected?)
        SInt32 isOffline = 0;
        MIDIObjectGetIntegerProperty(device, kMIDIPropertyOffline, &isOffline);
        NSLog(@"Device is online: %s", (isOffline ? "No" : "Yes"));
        
        // How many entities do we have?
        ItemCount entityCount = MIDIDeviceGetNumberOfEntities(device);
        NSLog(@"entityCount: %lu", entityCount);
        
        // Iterate through this device's entities
        for (ItemCount j = 0 ; j < entityCount ; ++j) {
            
            // Grab a reference to an entity
            MIDIEntityRef entity = MIDIDeviceGetEntity(device, j);
            NSLog(@"  Entity: %@", getName(entity));
            
            // Iterate through this device's source endpoints (MIDI In)
            ItemCount sourceCount = MIDIEntityGetNumberOfSources(entity);
            for (ItemCount k = 0 ; k < sourceCount ; ++k) {
                
                // Grab a reference to a source endpoint
                MIDIEndpointRef source = MIDIEntityGetSource(entity, k);
                NSLog(@"    Source: %@", getName(source));
            }
            
            // Iterate through this device's destination endpoints
            ItemCount destCount = MIDIEntityGetNumberOfDestinations(entity);
            for (ItemCount k = 0 ; k < destCount ; ++k) {
                
                // Grab a reference to a destination endpoint
                MIDIEndpointRef dest = MIDIEntityGetDestination(entity, k);
                NSLog(@"    Destination: %@", getName(dest));
            }
        }
        NSLog(@"------");
    }
}

void getMidiSources(){
    
    ItemCount sourceCount = MIDIGetNumberOfSources();
    
    for (NSInteger i = 0; i < sourceCount; i++) {
        
        MIDIEndpointRef endPointRef = MIDIGetSource(i);
        
        NSLog(@"Name: %@", getPropatyString(endPointRef, kMIDIPropertyName ));
        NSLog(@"DisplayName: %@", getPropatyString(endPointRef, kMIDIPropertyDisplayName ));
        NSLog(@"Model: %@", getPropatyString(endPointRef, kMIDIPropertyModel ));
        NSLog(@"Image: %@", getPropatyString(endPointRef, kMIDIPropertyImage ));
    }
}

static void
MIDIInputProc(const MIDIPacketList *pktlist,
              void *readProcRefCon, void *srcConnRefCon)
{
    MIDIPacket *packet = (MIDIPacket *)&(pktlist->packet[0]);
    UInt32 packetCount = pktlist->numPackets;
    
    for (NSInteger i = 0; i < packetCount; i++) {
        
        Byte mes = packet->data[0] & 0xF0;
        Byte ch = packet->data[0] & 0x0F;
        
        if ((mes == 0x90) && (packet->data[2] != 0)) {
            NSLog(@"note on number = %2.2x / velocity = %2.2x / channel = %2.2x",
                  packet->data[1], packet->data[2], ch);
        } else if (mes == 0x80 || mes == 0x90) {
            NSLog(@"note off number = %2.2x / velocity = %2.2x / channel = %2.2x",
                  packet->data[1], packet->data[2], ch);
        } else if (mes == 0xB0) {
            NSLog(@"cc number = %2.2x / data = %2.2x / channel = %2.2x",
                  packet->data[1], packet->data[2], ch);
        } else {
            NSLog(@"etc");
        }
        
        packet = MIDIPacketNext(packet);
    }
}


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    getMidiDevices();
    getMidiSources();
    
    OSStatus err;
    MIDIClientRef clientRef;
    MIDIPortRef inputPortRef;
    
    NSString *clientName = @"inputClient";
    err = MIDIClientCreate((CFStringRef)CFBridgingRetain(clientName), NULL, NULL, &clientRef);
    if (err != noErr) {
        NSLog(@"MIDIClientCreate err = %d", err);
        return ;
    }
    
    NSString *inputPortName = @"inputPort";
    err = MIDIInputPortCreate(
                              clientRef, (CFStringRef)CFBridgingRetain(inputPortName),
                              MIDIInputProc, NULL, &inputPortRef);
    if (err != noErr) {
        NSLog(@"MIDIInputPortCreate err = %d", err);
        return ;
    }
    
    ItemCount sourceCount = MIDIGetNumberOfSources();
    
    NSLog( @"errsourceCount = %lu", sourceCount );
    for (ItemCount i = 0; i < sourceCount; i++) {
        MIDIEndpointRef sourcePointRef = MIDIGetSource(i);
        err = MIDIPortConnectSource(inputPortRef, sourcePointRef, NULL);
        if (err != noErr) {
            NSLog(@"MIDIPortConnectSource err = %d", err);
            return ;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
