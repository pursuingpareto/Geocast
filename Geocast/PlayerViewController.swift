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
    var audioPlayer = PodcastPlayer.sharedInstance
    var isPlaying = false
    var timer: NSTimer!
    var episode: Episode?
    var progress: Float = 0.0
    var totalSeconds : Float = 0.0
    var popupText: String? = nil
    
    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var playedTime: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var locationTagButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var subscribeButton: UIButton!
    @IBOutlet weak var noEpisodeLabel: UILabel!
    
    
    
    @IBAction func playOrPause(sender: AnyObject) {

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
        let currentTime = Int(audioPlayer.currentTime().value) / Int(audioPlayer.currentTime().timescale)
        let minutes = currentTime / 60
        let seconds = currentTime - (minutes * 60)
        let currentFloatTime = Float(currentTime)
        progress = currentFloatTime / totalSeconds
        progressBar.setValue(progress, animated: true)
        playedTime.text = NSString(format: "%02d:%02d", minutes, seconds) as String
        
    }
    
    
    @IBAction func stop(sender: AnyObject) {
        audioPlayer.pause()
        audioPlayer.seekToTime(kCMTimeZero)
        isPlaying = false
    }
    
    @IBAction func progressBarChanged(sender: UISlider) {
        progress = sender.value
        let seconds = Int64(progress * totalSeconds)
        
        audioPlayer.seekToTime(CMTimeMake(seconds, 1))
        if isPlaying {
            audioPlayer.play()
        } else {
            audioPlayer.pause()
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if popupText != nil {
            displaySuccessfulTagPopup()
            popupText = nil
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressBar.addTarget(self, action: "progressBarChanged:", forControlEvents: .ValueChanged)

        if let episode = episode {
            var minsSecs = episode.duration.characters.split {$0 == ":"}.map { String($0) }
            let mins = (minsSecs[0] as NSString).integerValue
            let secs = (minsSecs[1] as NSString).integerValue
            totalSeconds = Float(60 * mins + secs)
            trackTitle.text = episode.title
            progressBar.value = 0
            
            
            let url = NSURL(string: episode.mp3Url)
            let playerItem = AVPlayerItem(URL: url!)
            audioPlayer.replaceCurrentItemWithPlayerItem(playerItem)
            
        }
        else {
            progressBar.hidden = true
            trackTitle.hidden = true
            playedTime.hidden = true
            playButton.hidden = true
            locationTagButton.hidden = true
            stopButton.hidden = true
            subscribeButton.hidden = true
            noEpisodeLabel.hidden = false
        }

    }
    
    func displaySuccessfulTagPopup() {
        let width = self.view.bounds.width / 2
        let height = width
        let center = self.view.center
        let origin = CGPoint(x: center.x - width/2, y: center.y - height/2)
        let size = CGSize(width: width, height: height)
        let frame = CGRect(origin: origin, size: size)
        print("frame is \(frame)")
        let popup = UILabel(frame: frame)
        popup.backgroundColor = UIColor.blackColor()
        popup.alpha = 0
        popup.text = popupText!
        popup.textColor = UIColor.whiteColor()
        popup.numberOfLines = 0
        popup.font = UIFont(name: (popup.font?.fontName)!, size: 20)
        popup.textAlignment = .Center
        popup.layer.cornerRadius = width / 10
        view.addSubview(popup)
        
        UIView.animateWithDuration(1.0, animations: {
            popup.alpha = 0.8
            }, completion: {
                (complete) in
                UIView.animateWithDuration(1.0, delay: 1.5, options: .CurveEaseInOut, animations: {
                    popup.alpha = 0
                    }, completion: {
                        (success) in
                        popup.removeFromSuperview()
                        self.popupText = nil
                })
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let destinationVC = segue.destinationViewController as? TagLocationController else {
            super.prepareForSegue(segue, sender: sender)
            return
        }
        
        if let episode = episode {
            destinationVC.episode = episode
            super.prepareForSegue(segue, sender: sender)
            
        }
        
    }
    
    @IBAction func cancelPlayerViewController(segue: UIStoryboardSegue) {
        segue.sourceViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}