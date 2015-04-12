//
//  AudioManager.swift
//  SwiftySequencer
//
//  Created by Ariel Elkin on 12/04/2015.
//

class AudioManager {

    private let audioController: AEAudioController
    private let woodblockSoundChannel: AESequencerChannel
    private let crickSoundChannel: AESequencerChannel

    private let reverb: AEAudioUnitFilter
    private let playbackRateFilter: AEAudioUnitFilter


    var reverbDryWet:Float = 0.0 {
        willSet {
            AudioUnitSetParameter(
                reverb.audioUnit,
                OSType(kReverb2Param_DryWetMix),
                OSType(kAudioUnitScope_Global),
                0,
                AudioUnitParameterValue(newValue),
                0);
        }
    }

    var playbackRateFilterRate:Float = 0.0 {
        willSet {
            AudioUnitSetParameter(
                playbackRateFilter.audioUnit,
                OSType(kVarispeedParam_PlaybackRate),
                OSType(kAudioUnitScope_Global),
                0,
                AudioUnitParameterValue(newValue),
                0);
        }
    }


    init() {

        //Init AEAudioController:
        audioController = AEAudioController(audioDescription: AEAudioController.nonInterleavedFloatStereoAudioDescription())


        /** Sequencer Channels **/

        //Setup woodblock channel:
        var woodblockURL = NSBundle.mainBundle().URLForResource("woodblock", withExtension: "caf")

        var woodblockSoundSequence = AESequencerChannelSequence()
        woodblockSoundSequence.addBeat(AESequencerBeat(onset: 0))
        woodblockSoundSequence.addBeat(AESequencerBeat(onset: 0.25))
        woodblockSoundSequence.addBeat(AESequencerBeat(onset: 0.50))
        woodblockSoundSequence.addBeat(AESequencerBeat(onset: 0.75))

        woodblockSoundChannel = AESequencerChannel(
            audioFileAt: woodblockURL,
            audioController: audioController,
            withSequence: woodblockSoundSequence,
            numberOfFullBeatsPerMeasure: 4,
            atBPM: 120)


        //Setup crick channel:
        var crickURL = NSBundle.mainBundle().URLForResource("crick", withExtension: "caf")

        var crickSoundSequence = AESequencerChannelSequence()
        crickSoundSequence.addBeat(AESequencerBeat(onset: 1.0 / 4 + 2.0 / 16, velocity:0.25))
        crickSoundSequence.addBeat(AESequencerBeat(onset: 2.0 / 4 + 1.0 / 16, velocity:0.5))
        crickSoundSequence.addBeat(AESequencerBeat(onset: 2.0 / 4 + 2.0 / 16, velocity:0.125))
        crickSoundSequence.addBeat(AESequencerBeat(onset: 2.0 / 4 + 3.0 / 16, velocity:0.5))
        crickSoundSequence.addBeat(AESequencerBeat(onset: 3.0 / 4 + 1.0 / 8, velocity:0.5))

        crickSoundChannel  = AESequencerChannel(
            audioFileAt: crickURL,
            audioController: audioController,
            withSequence: crickSoundSequence,
            numberOfFullBeatsPerMeasure: 4,
            atBPM: 120)


        //Add sequencer channels to audio controller:
        audioController.addChannels([crickSoundChannel])
        audioController.addChannels([woodblockSoundChannel])


        /** Effects **/
        var errorEffectSetup: NSError?

        //Setup Reverb:
        var reverbDescription = AEAudioComponentDescriptionMake(
            OSType(kAudioUnitManufacturer_Apple),
            OSType(kAudioUnitType_Effect),
            OSType(kAudioUnitSubType_Reverb2))

        reverb = AEAudioUnitFilter(
            componentDescription: reverbDescription,
            audioController: audioController,
            error: &errorEffectSetup)

        if (errorEffectSetup != nil) {
            println("Error setting up reverb: \(errorEffectSetup)");
        }

        audioController.addFilter(reverb, toChannel: crickSoundChannel)


        //Setup playback rate filter:
        var pitchFilterDescription = AEAudioComponentDescriptionMake(
            OSType(kAudioUnitManufacturer_Apple),
            OSType(kAudioUnitType_FormatConverter),
            OSType(kAudioUnitSubType_Varispeed))

        playbackRateFilter = AEAudioUnitFilter(
            componentDescription: pitchFilterDescription,
            audioController: audioController,
            error:&errorEffectSetup)


        if errorEffectSetup != nil {
            println("Error setting up pitch filter: \(errorEffectSetup)");
        }

        audioController.addFilter(playbackRateFilter, toChannel: woodblockSoundChannel)

    }

    func start() {
        var audioControllerStartError: NSError?
        var success = audioController.start(&audioControllerStartError)
        if (!success) {
            println("audioControllerStartError: \(audioControllerStartError)")
        }
        crickSoundChannel.sequenceIsPlaying = true
        woodblockSoundChannel.sequenceIsPlaying = true
    }
    
    func stop() {
        audioController.stop()
        crickSoundChannel.sequenceIsPlaying = false
        woodblockSoundChannel.sequenceIsPlaying = false
        
    }
}
