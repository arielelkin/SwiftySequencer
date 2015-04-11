//
//  ViewController.swift
//  SwiftySequencer
//
//  Created by Ariel Elkin on 10/04/2015.
//  Copyright (c) 2015 Ariel. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var audioManager = AudioManager()

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    func reverbSizeSliderMoved(sender:UISlider) {
        audioManager.reverbDryWet = sender.value
        println("reverb dry wet: \(audioManager.reverbDryWet)")
    }

    func playbackRateSliderMoved(sender:UISlider) {
        audioManager.playbackRateFilterRate = sender.value
        println("playback rate: \(audioManager.playbackRateFilterRate)")
    }

}

class AudioManager {
    private let audioController: AEAudioController
    private var woodblockSoundChannel: AESequencerChannel
    private var crickSoundChannel: AESequencerChannel

    private var reverb: AEAudioUnitFilter
    private var playbackRateFilter: AEAudioUnitFilter


    var reverbDryWet:Float = 0.0 {
        willSet {
            var status = AudioUnitSetParameter(
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

        var audioControllerStartError: NSError?
        var success = audioController.start(&audioControllerStartError)
        if (!success) {
            println("audioControllerStartError: \(audioControllerStartError)")
        }

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
        crickSoundChannel.sequenceIsPlaying = true


        audioController.addChannels([woodblockSoundChannel])
        woodblockSoundChannel.sequenceIsPlaying = true


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

}

extension ViewController {

    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor.whiteColor()


        var reverbLabel = UILabel()
        reverbLabel.text = "Reverb dry/wet:"
        reverbLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(reverbLabel)


        var reverbSlider = UISlider()
        reverbSlider.minimumValue = 0.0
        reverbSlider.maximumValue = 100.0
        reverbSlider.addTarget(self, action: "reverbSizeSliderMoved:", forControlEvents: UIControlEvents.ValueChanged)
        reverbSlider.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(reverbSlider)


        var playbackRateLabel = UILabel()
        playbackRateLabel.text = "Playback Rate:"
        playbackRateLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(playbackRateLabel)

        var playbackRateSlider = UISlider()
        playbackRateSlider.minimumValue = -5.0
        playbackRateSlider.maximumValue = 5.0
        playbackRateSlider.addTarget(self, action: "playbackRateSliderMoved:", forControlEvents: UIControlEvents.ValueChanged)
        playbackRateSlider.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(playbackRateSlider)




        var viewsDict = ["reverbLabel": reverbLabel,
        "reverbSlider": reverbSlider,
        "playbackRateLabel": playbackRateLabel,
        "playbackRateSlider": playbackRateSlider]

        var metrics = ["vSpacing": 20]

        var horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-[reverbLabel]",
            options: NSLayoutFormatOptions.allZeros,
            metrics: nil,
            views: viewsDict)
        view.addConstraints(horizontalConstraints)

        horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-[reverbSlider]-|",
            options: NSLayoutFormatOptions.allZeros,
            metrics: nil,
            views: viewsDict)
        view.addConstraints(horizontalConstraints)

        horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-[playbackRateLabel]",
            options: NSLayoutFormatOptions.allZeros,
            metrics: nil,
            views: viewsDict)
        view.addConstraints(horizontalConstraints)

        horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-[playbackRateSlider]-|",
            options: NSLayoutFormatOptions.allZeros,
            metrics: nil,
            views: viewsDict)
        view.addConstraints(horizontalConstraints)

        var verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-30-[reverbLabel]-vSpacing-[reverbSlider]-vSpacing-[playbackRateLabel]-vSpacing-[playbackRateSlider]",
            options: NSLayoutFormatOptions.allZeros,
            metrics: metrics,
            views: viewsDict)
        view.addConstraints(verticalConstraints)

    }
}
