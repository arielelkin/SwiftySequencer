//
//  ViewController.swift
//  SwiftySequencer
//
//  Created by Ariel Elkin on 10/04/2015.
//  Copyright (c) 2015 Ariel. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        var audioManager = AudioManager()
    }

}

class AudioManager {
    let audioController: AEAudioController
    var woodblockSoundChannel: AESequencerChannel
    var crickSoundChannel: AESequencerChannel


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


    }

}

