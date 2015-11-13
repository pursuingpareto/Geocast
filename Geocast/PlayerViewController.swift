//
//  PlayerViewController.swift
//  Geocast
//
//  Created by Andrew Brown on 11/5/15.
//  Copyright (c) 2015 Andrew Brown. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class PlayerViewController: UIViewController {
    
    @IBOutlet weak var progressBar: UISlider!
    var audioPlayer = PodcastPlayer.sharedInstance
    var isPlaying = false
    var timer: NSTimer!
    var episode: Episode?
    var progress: Float = 0.0
    var totalSeconds : Float = 0.0
    var popupText: String? = nil
    var imageCache = [String : UIImage]()
    var image: UIImage?

    
    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var podcastTitle: UILabel!
    @IBOutlet weak var episodeSummary: UITextView!
    @IBOutlet weak var playedTime: UILabel!
    @IBOutlet weak var remainingTime: UILabel!
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
        
        let remainingIntTime = Int(totalSeconds) - currentTime
        let remainingMinutes = Int(remainingIntTime) / 60
        let remainingSeconds = remainingIntTime - (remainingMinutes * 60)
        
        progress = currentFloatTime / totalSeconds
        progressBar.setValue(progress, animated: true)
        playedTime.text = NSString(format: "%02d:%02d", minutes, seconds) as String
        remainingTime.text = NSString(format: "%02d:%02d", remainingMinutes, remainingSeconds) as String
    }
    
    func setTextForSubscribeButton() {
        if let episode = episode {
            if User.sharedInstance.isSubscribedTo((episode.podcast)!) {
                subscribeButton.setTitle("Unsubscribe", forState: .Normal)
            } else {
                subscribeButton.setTitle("Subscribe", forState: .Normal)
            }
        }
    }
    
    @IBAction func subscribeButtonPressed(sender: UIButton) {
        if User.sharedInstance.isSubscribedTo((episode?.podcast)!) {
            // TODO add confirmation popup?
            
            let message = "Are you sure you want to unsubscribe from \(episode?.podcast.title)?"
            let alertController = UIAlertController(title: "Confirm Unsubscribe", message: message, preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
                (alert) in
            })
            alertController.addAction(cancelAction)
            
            let confirmAction = UIAlertAction(title: "Unsubscribe", style: .Default, handler: {
                (alert) in
                print("Confirming unsubscribe...")
                User.sharedInstance.unsubscribe((self.episode?.podcast)!)
            })
            alertController.addAction(confirmAction)
            self.presentViewController(alertController, animated: true, completion: {
                
            })
        } else {
            print("subscribe button pressed, attempting to subscribe...")
            User.sharedInstance.subscribe((episode?.podcast)!)
        }
        setTextForSubscribeButton()
    }
    
    @IBAction func stop(sender: AnyObject) {
        audioPlayer.pause()
        audioPlayer.seekToTime(kCMTimeZero)
        isPlaying = false
    }
    
    @IBAction func progressBarChanged(sender: UISlider) {
        print("Progress bar changed")
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
        print("VIEW WILL APPEAR")
        super.viewWillAppear(animated)
        setTextForSubscribeButton()
        if let episode = PodcastPlayer.sharedInstance.episode {
            print("Assigned episode to PodcastPlayer's episode")
            assignImage(episode.podcast.largeImageURL)
            
            var minsSecs = episode.duration.characters.split {$0 == ":"}.map { String($0) }
            
            let mins: Int!
            let secs: Int!
            if minsSecs.count == 2 {
                mins = (minsSecs[0] as NSString).integerValue
                secs = (minsSecs[1] as NSString).integerValue
            } else {
                // TODO - fix this hacky solution to some poorly formatted durations.
                mins = 10
                secs = 10
            }
            
            remainingTime.text = NSString(format: "%02d:%02d", mins, secs) as String
            totalSeconds = Float(60 * mins + secs)
            trackTitle.text = episode.title
            podcastTitle.text = episode.podcast.title
            episodeSummary.text = episode.itunesSubtitle
            progressBar.value = 0
            
            
            let url = NSURL(string: episode.mp3Url)
            let playerItem = AVPlayerItem(URL: url!)
            audioPlayer.replaceCurrentItemWithPlayerItem(playerItem)
            
            //            let albumArt = MPMediaItemArtwork(image: image!)
            
            if NSClassFromString("MPNowPlayingInfoCenter") != nil {
                var songInfo = [
                    MPMediaItemPropertyArtist: episode.podcast.title,
                    MPMediaItemPropertyTitle: episode.title,
                    MPMediaItemPropertyPlaybackDuration: String(totalSeconds),
                    //                    MPMediaItemPropertyArtwork: albumArt
                ]
                MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = songInfo as [String : AnyObject]
            }
            
            try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: [])
            try! AVAudioSession.sharedInstance().setActive(true)
            
            do {
                UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
            }
            catch {
                print("Audio session error.")
            }
            
            //            if (AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)) {
            //                print("Receiving remote control events"),
            //                UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
            //            }
            //            else {
            //                print("Audio Session error.")
            //            }
            
            progressBar.hidden = false
            trackTitle.hidden = false
            podcastTitle.hidden = false
            episodeSummary.hidden = false
            remainingTime.hidden = false
            playedTime.hidden = false
            playButton.hidden = false
            locationTagButton.hidden = false
            stopButton.hidden = false
            subscribeButton.hidden = false
            noEpisodeLabel.hidden = true
        }
        else {
            progressBar.hidden = true
            trackTitle.hidden = true
            podcastTitle.hidden = true
            episodeSummary.hidden = true
            remainingTime.hidden = true
            playedTime.hidden = true
            playButton.hidden = true
            locationTagButton.hidden = true
            stopButton.hidden = true
            subscribeButton.hidden = true
            noEpisodeLabel.hidden = false
        }
        
            
        if popupText != nil {
            displaySuccessfulTagPopup()
            popupText = nil
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressBar.addTarget(self, action: "progressBarChanged:", forControlEvents: .ValueChanged)
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        if event!.type == UIEventType.RemoteControl {
            if event?.subtype == UIEventSubtype.RemoteControlPlay {
                audioPlayer.play()
                print("remote play")
            }
            else if event?.subtype == UIEventSubtype.RemoteControlPause {
                audioPlayer.pause()
                print("remote pause")
            }
            else if event?.subtype == UIEventSubtype.RemoteControlNextTrack {
                // Put in logic to move to next track
            }
            else if event?.subtype == UIEventSubtype.RemoteControlPreviousTrack {
                // Put in logic to move to previous track
            }

        }
    }
    
    func assignImage(url:String) {
        
        var imgURL: NSURL = NSURL(string: url)!
        image = self.imageCache[url]
        if image == nil {
            let request: NSURLRequest = NSURLRequest(URL: imgURL)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                if error == nil {
                    self.image = UIImage(data: data!)
                    
                    // Store the image in to our cache
                    self.imageCache[url] = self.image
                    print(self.image)
                } else {
                    print("Error: \(error!.localizedDescription)")
                }
            })
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