//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Jeffrey Martin on 3/5/15.
//  Copyright (c) 2015 Jeffrey Martin. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    var audioRecorder:AVAudioRecorder!
    var recordedAudio:RecordedAudio!
    
    ///Flag that indicates if the recording is in a paused state. True when the recording is paused.
    var isRecordingPaused = false

    @IBOutlet weak var recordingInProgress: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var pauseRecordingButton: UIButton!
    
        
    override func viewWillAppear(animated: Bool) {
        stopButton.hidden = true
        recordButton.enabled = true
        pauseRecordingButton.hidden = true
        
        setPauseButtonImage("pause")
        
    }
    
    @IBAction func pauseButton(sender: UIButton) {
        // If the recording is paused and the pause button is tapped we want to resume the recording
        
        if(isRecordingPaused) {
            isRecordingPaused = false
            recordingInProgress.text = "Recording In Progress"
            audioRecorder.record()
            
            setPauseButtonImage("pause")
        } else {
            isRecordingPaused = true
            recordingInProgress.text = "Recording Paused"
            audioRecorder.pause()
            
            setPauseButtonImage("resume")
        }
    }
    
    @IBAction func recordAudio(sender: UIButton) {
        
        toggleRecordingInProgressText(true)
        
        stopButton.hidden = false
        pauseRecordingButton.hidden = false
        recordButton.enabled = false
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
            .UserDomainMask, true)[0] as String
        
        let currentDateTime = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        let recordingName = formatter.stringFromDate(currentDateTime) + ".wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        println(filePath)
        
        var session = AVAudioSession.sharedInstance()
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error:nil)
        
        audioRecorder = AVAudioRecorder(URL: filePath, settings:nil, error:nil)
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
       
    }
    
    ///Sets the image of the Pause button.
    ///
    ///:param: String 'image' The name of the image to use in the Pause Recording button. Values can be either pause or resume
    func setPauseButtonImage(image: String) {
        var buttonImage = UIImage(named:image)
        pauseRecordingButton.setImage(buttonImage, forState: .Normal)

    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        if(flag) {
            recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent!)
            
            self.performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        } else {
            println("Recording was not successful")
            recordButton.enabled = true
            stopButton.hidden = true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "stopRecording") {
            let playSoundsVC:PlaySoundsViewController = segue.destinationViewController as PlaySoundsViewController
            let data = sender as RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }

    @IBAction func stopRecording(sender: UIButton) {
        toggleRecordingInProgressText(false)
        
        audioRecorder.stop()
        var audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false,error: nil)
    }
    
    func toggleRecordingInProgressText(isRecording: Bool) {
        let recordingText = "Recording in Progress"
        let idleText = "Tap to Record"
        
        recordingInProgress.text = isRecording ? recordingText : idleText
    }
}

