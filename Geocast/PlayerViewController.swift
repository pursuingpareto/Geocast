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
    @IBOutlet weak var publicationDate: UILabel!
    
    @IBOutlet weak var episodeSummary: UITextView!
    @IBOutlet weak var playedTime: UILabel!
    @IBOutlet weak var remainingTime: UILabel!
    @IBOutlet weak var locationTagButton: UIButton!
    @IBOutlet weak var subscribeButton: UIButton!
    @IBOutlet weak var noEpisodeLabel: UILabel!
    
    @IBOutlet weak var toolbarPlayButton: UIBarButtonItem!
    
    @IBOutlet weak var playbackToolbar: UIToolbar!
    

    
    @IBAction func toolbarPlayOrPause(sender: AnyObject) {
        
        var btn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Play, target: self, action: "toolbarPlayOrPause:")
        
        if isPlaying {
            audioPlayer.pause()
            isPlaying = false
            timer.invalidate()
        } else {
            audioPlayer.play()
            btn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Pause, target: self, action: "toolbarPlayOrPause:")
            isPlaying = true
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "updateTime", userInfo: nil, repeats: true)
        }
        var items = playbackToolbar.items!
        items[3] = btn
        playbackToolbar.setItems(items, animated: true)
        
        
    }
    
    func updateTime() {
        

        let currentTime = Int(Float(audioPlayer.currentTime().value) / Float(audioPlayer.currentTime().timescale))

        
        let minutes = currentTime / 60
        let seconds = currentTime - (minutes * 60)
        let currentFloatTime = Float(currentTime)

        episode?.approximateSecondsListenedToByUser += 1
        
        
        let remainingIntTime = Int(totalSeconds) - currentTime
        let remainingMinutes = Int(remainingIntTime) / 60
        let remainingSeconds = remainingIntTime - (remainingMinutes * 60)
        
        progress = currentFloatTime / totalSeconds
        episode?.progress = progress

        if currentTime % 10 == 0 {
            episode?.progress = progress
            print("progress \(progress)")
            User.sharedInstance.updateOneLocalEpisode(forPodcast: self.episode!.podcast, withEpisode: episode!)
        }

        print("progress made \(episode?.progress)")
        
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
        } else {

        }
    }
    
    @IBAction func subscribeButtonPressed(sender: UIButton) {
        if User.sharedInstance.isSubscribedTo((episode?.podcast)!) {
            // TODO add confirmation popup?
            
            let message = "Are you sure you want to unsubscribe from \(episode!.podcast.title)?"
            let alertController = UIAlertController(title: "Confirm Unsubscribe", message: message, preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
                (alert) in
            })
            alertController.addAction(cancelAction)
            
            let confirmAction = UIAlertAction(title: "Unsubscribe", style: .Default, handler: {
                (alert) in

                User.sharedInstance.unsubscribe((self.episode?.podcast)!)
                self.setTextForSubscribeButton()
            })
            alertController.addAction(confirmAction)
            self.presentViewController(alertController, animated: true, completion: {
                
            })
        } else {

            User.sharedInstance.subscribe((episode?.podcast)!)
        }
        setTextForSubscribeButton()
    }
    
//    @IBAction func stop(sender: AnyObject) {
//        audioPlayer.pause()
//        audioPlayer.seekToTime(kCMTimeZero)
//        isPlaying = false
//    }
    
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
    
    private var myContext = 0
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == &myContext {
            if let newValue = change?[NSKeyValueChangeNewKey] {

                let totalSecs = CMTimeGetSeconds((audioPlayer.currentItem?.duration)!)
                totalSeconds = Float(totalSecs)
                let mins = Int(totalSecs / 60.0)
                let secs = Int(totalSecs) - 60 * mins

                episode?.duration = Int(totalSecs)

                updateTime()
            } else {
                super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            }
            
        }
    }
    
    deinit {
        
        audioPlayer.currentItem?.removeObserver(self, forKeyPath: "duration", context: &myContext)
    }
    
    @IBAction func fastForwardPressed(sender: AnyObject) {
        let seconds = CMTimeMake(15, 1)
        let currentTime = audioPlayer.currentTime()
        let newTime = currentTime + seconds
        
        audioPlayer.seekToTime(newTime)
    }
    
    
    @IBAction func rewindPressed(sender: AnyObject) {
        let seconds = CMTimeMake(-15, 1)
        let currentTime = audioPlayer.currentTime()
        let newTime = currentTime + seconds
        
        audioPlayer.seekToTime(newTime)
    }
    
    
    override func viewWillAppear(animated: Bool) {
//        setup()
        print("PLAYER VIEW WILL APPEAR")

        super.viewWillAppear(animated)
        
        if !isPlaying {
            for item in playbackToolbar.items! {
                item.enabled = false
            }
        }
        
        
        if let ep = PodcastPlayer.sharedInstance.episode {
            episode = ep
            setTextForSubscribeButton()

            assignImage(episode!.podcast.largeImageURL)
            
//            var minsSecs = episode!.duration.characters.split {$0 == ":"}.map { String($0) }
            
            let mins: Int!
            let secs: Int!
            if episode?.duration != nil {
                mins = episode!.duration! / 60
                secs = episode!.duration! - 60 * mins
            } else {
                // TODO - fix this hacky solution to some poorly formatted durations.
                mins = 10
                secs = 10
            }
            
            remainingTime.text = NSString(format: "%02d:%02d", mins, secs) as String
            totalSeconds = Float(60 * mins + secs)

            trackTitle.text = episode!.title
            podcastTitle.text = episode!.podcast.title
            episodeSummary.text = episode!.itunesSubtitle
            
            // TODO - fix this! Will fail eventually!
            let pubDate = episode!.pubDate.substringToIndex(episode!.pubDate.startIndex.advancedBy(16))
            publicationDate.text = pubDate
            progressBar.value = 0
            
            
            let url = NSURL(string: episode!.mp3Url)
            print("about to get player item")
            dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
                let playerItem = AVPlayerItem(URL: url!)
                
                if playerItem.asset.tracks.first?.trackID != PodcastPlayer.sharedInstance.currentItem?.asset.tracks.first?.trackID {
                    print("NEW PLAYER ITEM")
                    dispatch_async(dispatch_get_main_queue(), {
                        self.setupAudioPlayer(playerItem)
                        for item in self.playbackToolbar.items! {
                            item.enabled = true
                        }
                        print("got player item")
                    })
                } else {
                    print("OLD PLAYER ITEM")
                    for item in self.playbackToolbar.items! {
                        item.enabled = true
                    }
                }
                
                
            }

            
            
//            setupAudioPlayer(playerItem)
            
            
            progressBar.hidden = false
            trackTitle.hidden = false
            podcastTitle.hidden = false
            episodeSummary.hidden = false
            remainingTime.hidden = false
            playedTime.hidden = false
            locationTagButton.hidden = false
            subscribeButton.hidden = false
            noEpisodeLabel.hidden = true
            publicationDate.hidden = false
            playbackToolbar.hidden = false
        }
        else {
            progressBar.hidden = true
            trackTitle.hidden = true
            podcastTitle.hidden = true
            episodeSummary.hidden = true
            remainingTime.hidden = true
            playedTime.hidden = true
            locationTagButton.hidden = true
            subscribeButton.hidden = true
            noEpisodeLabel.hidden = false
            publicationDate.hidden = true
            playbackToolbar.hidden = true
        }
        
            
        if popupText != nil {
            displaySuccessfulTagPopup()
            popupText = nil
        }
    }
    
    func setupAudioPlayer(playerItem: AVPlayerItem) {
        audioPlayer.replaceCurrentItemWithPlayerItem(playerItem)
        audioPlayer.currentItem?.addObserver(self, forKeyPath: "duration", options: .New, context: &myContext)

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
//        audioPlayer.currentItem?.removeObserver(self, forKeyPath: "duration", context: &myContext)
    }
    
    
    
    func setupRemoteControl(image: UIImage?) {
        if NSClassFromString("MPNowPlayingInfoCenter") != nil {
            let podcastArt = MPMediaItemArtwork(image: image!)
            var songInfo = [
                MPMediaItemPropertyArtist: episode!.podcast.title,
                MPMediaItemPropertyTitle: episode!.title,
                MPMediaItemPropertyPlaybackDuration: String(totalSeconds),
                MPMediaItemPropertyArtwork: podcastArt
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
        
    }
    
    override func viewDidLoad() {
        print("PLAYER VIEW DID LOAD")
        super.viewDidLoad()
        progressBar.addTarget(self, action: "progressBarChanged:", forControlEvents: .ValueChanged)
        let verticalBar = UIImage(named: "vertical_bar")
        let size = CGSizeApplyAffineTransform((verticalBar?.size)!, CGAffineTransformMakeScale(0.2, 0.2))
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        verticalBar!.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledBar = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        progressBar.setThumbImage(scaledBar, forState: .Normal)
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        if event!.type == UIEventType.RemoteControl {
            if event?.subtype == UIEventSubtype.RemoteControlPlay {
                audioPlayer.play()
                print("remote play")
                timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "updateTime", userInfo: nil, repeats: true)

            }
            else if event?.subtype == UIEventSubtype.RemoteControlPause {
                audioPlayer.pause()
                print("remote pause")
                timer.invalidate()
            }
            else if event?.subtype == UIEventSubtype.RemoteControlNextTrack {
                // Put in logic to move to next track
                print("remote forward")
                let seconds = CMTimeMake(15, 1)
                let currentTime = audioPlayer.currentTime()
                let newTime = currentTime + seconds
                
                audioPlayer.seekToTime(newTime)

            }
            else if event?.subtype == UIEventSubtype.RemoteControlPreviousTrack {
                // Put in logic to move to previous track
                print("remote rewind")
                let seconds = CMTimeMake(-15, 1)
                let currentTime = audioPlayer.currentTime()
                let newTime = currentTime + seconds
                
                audioPlayer.seekToTime(newTime)

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
                    
                    self.setupRemoteControl(self.image)
                    print("image for remote control \(self.image)")
                } else {
                    print("Error: \(error!.localizedDescription)")
                    self.setupRemoteControl(self.image)
                }
            })
        }
        else {
            self.setupRemoteControl(self.image)
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
        
        if let tagVC = segue.destinationViewController as? TagLocationController {
            tagVC.episode = episode
        }
        super.prepareForSegue(segue, sender: sender)
        
//        guard let destinationVC = segue.destinationViewController as? TagLocationController else {
//            super.prepareForSegue(segue, sender: sender)
//            return
//        }
//        
//        if let episode = episode {
//            destinationVC.episode = episode
//            super.prepareForSegue(segue, sender: sender)
//            
//        }
        
    }
    
    @IBAction func cancelPlayerViewController(segue: UIStoryboardSegue) {
        segue.sourceViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}