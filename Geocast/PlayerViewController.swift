//
//  PlayerViewController.swift
//  Geocast
//
//  Created by Andrew Brown on 11/5/15.
//  Copyright (c) 2015 Andrew Brown. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {
    
    @IBOutlet weak var progressBar: UISlider!
    var audioPlayer = AVPlayer()
    var isPlaying = false
    var timer: NSTimer!
    var episode: Episode!
    var progress: Float = 0.0
    var totalSeconds : Float = 0.0
    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var playedTime: UILabel!
    
    @IBAction func playOrPause(sender: AnyObject) {
        println(audioPlayer)
        if isPlaying {
            audioPlayer.pause()
            isPlaying = false
        } else {
            audioPlayer.play()
            isPlaying = true
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "updateTime", userInfo: nil, repeats: true)
    }
    
    func updateTime() {
        var currentTime = Int(audioPlayer.currentTime().value) / Int(audioPlayer.currentTime().timescale)
        var minutes = currentTime / 60
        var seconds = currentTime - (minutes * 60)
        var currentFloatTime = Float(currentTime)
        progress = currentFloatTime / totalSeconds
        progressBar.setValue(progress, animated: true)
        playedTime.text = NSString(format: "%02d:%02d", minutes, seconds) as String
        
        println("totalSeconds: \(totalSeconds)\nprogress: \(progress)\ncurrentFloatTime: \(currentFloatTime)\n\n")
    }
    
    
    @IBAction func stop(sender: AnyObject) {
        audioPlayer.pause()
        audioPlayer.seekToTime(kCMTimeZero)
        isPlaying = false
    }
    
    @IBAction func progressBarChanged(sender: UISlider) {
        progress = sender.value
        var seconds = Int64(progress * totalSeconds)
        
        audioPlayer.seekToTime(CMTimeMake(seconds, 1))
        if isPlaying {
            audioPlayer.play()
        } else {
            audioPlayer.pause()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressBar.addTarget(self, action: "progressBarChanged:", forControlEvents: .ValueChanged)
        println("EPISODE DURATION IS \(episode.duration)")
        var minsSecs = split(episode.duration) {$0 == ":"}
        var mins = (minsSecs[0] as NSString).integerValue
        var secs = (minsSecs[1] as NSString).integerValue
        totalSeconds = Float(60 * mins + secs)
        trackTitle.text = episode.title
        progressBar.value = 0
        
        println(episode.description)

        let url = NSURL(string: episode.mp3Url)
        let playerItem = AVPlayerItem(URL: url!)
        audioPlayer = AVPlayer(playerItem: playerItem)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}