//
//  CallViewController.swift
//  Sinch test
//
//  Created by Logesh R on 30/11/17.
//  Copyright © 2017 Logesh R. All rights reserved.
//

import UIKit

class CallViewController:UIViewController,SINCallDelegate {
    
    @IBAction func endCall(_ sender: Any) {
        print("End Call Pressed")
        call.hangup()
        
    }
    
    @IBOutlet weak var callStatusText: UILabel!
    var durationTimer: Timer?
    var call: SINCall!
    
    func audioController() -> SINAudioController {
        return ( (UIApplication.shared.delegate as! AppDelegate).client.audioController()) 
    }
    
    func setCall(_ call: SINCall) {
        self.call = call
        call.delegate = self
    }
    
    // MARK: - UIViewController Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if call.direction == .incoming {
            if ((UIApplication.shared.delegate as! AppDelegate).callKitProvider?.callExists(call)) != nil {
                callStatusText.text = ""
                
            }
            else {
                callStatusText.text = ""
                
                audioController().startPlayingSoundFile(path(forSound: "incoming.wav"), loop: true)
            }
        }
        else {
            callStatusText.text = "calling..."
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        callStatusText.text = call.remoteUserId
    }
    
    // MARK: - Call Actions
    @IBAction func accept(_ sender: Any) {
        audioController().stopPlayingSoundFile()
        call.answer()
    }
    
    @IBAction func decline(_ sender: Any) {
        call.hangup()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func hangup(_ sender: Any) {
        call.hangup()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func onDurationTimer(_ unused: Timer) {
        let duration = Int(Date().timeIntervalSince(call.details.establishedTime))
        
    }
    
    // MARK: - SINCallDelegate
    func callDidProgress(_ call: SINCall) {
        callStatusText.text = "ringing..."
        audioController().startPlayingSoundFile(path(forSound: "ringback.wav"), loop: true)
    }
    
    func callDidEstablish(_ call: SINCall) {
        
        audioController().stopPlayingSoundFile()
    }
    
    func callDidEnd(_ call: SINCall) {
        
        audioController().stopPlayingSoundFile()
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    // MARK: - Sounds
    func path(forSound soundName: String) -> String {
        return URL(fileURLWithPath: Bundle.main.resourcePath ?? "").appendingPathComponent(soundName).absoluteString
    }
}
