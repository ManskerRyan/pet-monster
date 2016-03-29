//
//  ViewController.swift
//  Pet-Monster
//
//  Created by Ryan Alexander Mansker on 3/28/16.
//  Copyright © 2016 Ryan Alexander Mansker. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    //MARK: Properties
    @IBOutlet weak var monsterImg: MonsterImg!
    @IBOutlet weak var heartImg: DragImg!
    @IBOutlet weak var foodImg: DragImg!
    @IBOutlet weak var penalty1Img: UIImageView!
    @IBOutlet weak var penalty2Img: UIImageView!
    @IBOutlet weak var penalty3Img: UIImageView!
        //Constants
    let DIM_ALPHA: CGFloat = 0.2
    let OPAQUE: CGFloat = 1.0
    let MAX_PENALTIES = 3
        //Variables
    var penalties = 0
    var timer: NSTimer!
    var monsterHappy = false
    var currentItem: UInt32 = 0
        //Audio variables
    var musicPlayer = AVAudioPlayer()
    var sfxBite = AVAudioPlayer()
    var sfxHeart = AVAudioPlayer()
    var sfxDeath = AVAudioPlayer()
    var sfxSkull = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAudio(&musicPlayer, fileName: "cave-music", fileType: "mp3")
        loadAudio(&sfxBite, fileName: "bite", fileType: "wav")
        loadAudio(&sfxHeart, fileName: "heart", fileType: "wav")
        loadAudio(&sfxDeath, fileName: "death", fileType: "wav")
        loadAudio(&sfxSkull, fileName: "skull", fileType: "wav")
        prepareAudio()
        
        musicPlayer.numberOfLoops = -1
        musicPlayer.play()
        
        foodImg.dropTarget = monsterImg
        heartImg.dropTarget = monsterImg
        
        penalty1Img.alpha = DIM_ALPHA
        penalty2Img.alpha = DIM_ALPHA
        penalty3Img.alpha = DIM_ALPHA
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.itemDroppedOnCharacter(_:)), name: "onTargetDropped", object: nil)
        
        startTimer()
    }
    
    //MARK: Functions
    func prepareAudio() {
        musicPlayer.prepareToPlay()
        sfxBite.prepareToPlay()
        sfxHeart.prepareToPlay()
        sfxSkull.prepareToPlay()
        sfxDeath.prepareToPlay()
    }
    
    func loadAudio(inout fxName: AVAudioPlayer, fileName: String, fileType: String) {
        let path = NSBundle.mainBundle().pathForResource(fileName, ofType: fileType)
        let soundUrl = NSURL(fileURLWithPath: path!)
        
        do {
            try fxName = AVAudioPlayer(contentsOfURL: soundUrl)
        } catch let err as NSError {
            print(err.debugDescription)
        }
    }
    
    func itemDroppedOnCharacter(notif: NSNotification) {
        monsterHappy = true
        startTimer()
        
        foodImg.alpha = DIM_ALPHA
        foodImg.userInteractionEnabled = false
        heartImg.alpha = DIM_ALPHA
        heartImg.userInteractionEnabled = false
        
        if currentItem == 0 {
            sfxHeart.play()
        } else {
            sfxBite.play()
        }
    }
    
    func startTimer() {
        if timer != nil {
            timer.invalidate()
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector:#selector(ViewController.changeGameState), userInfo: nil, repeats: true)
    }
    
    func changeGameState() {
        if !monsterHappy {
            penalties = penalties + 1
            sfxSkull.play()
            
            if penalties == 1 {
                penalty1Img.alpha = OPAQUE
                penalty2Img.alpha = DIM_ALPHA
            }else if penalties == 2 {
                penalty2Img.alpha = OPAQUE
                penalty3Img.alpha = DIM_ALPHA
            } else if penalties >= 3 {
                penalty3Img.alpha = OPAQUE
            } else {
                penalty1Img.alpha = DIM_ALPHA
                penalty2Img.alpha = DIM_ALPHA
                penalty3Img.alpha = DIM_ALPHA
            }
            
            if penalties >= MAX_PENALTIES {
                gameOver()
            }
        }
        
        let rand = arc4random_uniform(2) //0 or 1
        if rand == 0 {
            foodImg.alpha = DIM_ALPHA
            foodImg.userInteractionEnabled = false
            
            heartImg.alpha = OPAQUE
            heartImg.userInteractionEnabled = true
        } else {
            heartImg.alpha = DIM_ALPHA
            heartImg.userInteractionEnabled = false
            
            foodImg.alpha = OPAQUE
            foodImg.userInteractionEnabled = true
        }
        
        currentItem = rand
        monsterHappy = false
    }
    
    func gameOver() {
        timer.invalidate()
        sfxDeath.play()
        monsterImg.playDeathAnimation()
    }
}