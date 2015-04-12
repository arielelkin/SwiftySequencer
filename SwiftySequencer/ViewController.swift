//
//  ViewController.swift
//  SwiftySequencer
//
//  Created by Ariel Elkin on 10/04/2015.
//  Copyright (c) 2015 Ariel. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var audioManager: AudioManager {
        var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.audioManager
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



extension ViewController {

    //Setup UI
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
