//
//  ViewController.swift
//  Derecho
//
//  Created by Niranjan Ravichandran on 8/1/17.
//  Copyright © 2017 Aviato. All rights reserved.
//

import UIKit
import UserNotifications
import AVFoundation

struct Constants {
    static let night = "https://cdn.dribbble.com/users/658318/screenshots/2772561/dia-dos-namorados.gif"
    static let day = "https://cdn.dribbble.com/users/99875/screenshots/1458439/pharrell_drib.gif"//"https://cdn.dribbble.com/users/485324/screenshots/2514828/service_down_page.gif"
    static let minion = "https://cdn.dribbble.com/users/1601212/screenshots/3351646/minions.gif"
    static let switchKey = "DUISwicthKey"
    static let reminder = "everyday"
}

class ViewController: UIViewController, SettingsDelegate, AVAudioPlayerDelegate {
    
    
    var dswitch: DUISwicth!
    var bgView: UIImageView!
    var newBg: UIImageView!
    let defaults = UserDefaults.standard
    var statusLabel: UILabel!
    var emojis = ["😉", "🐶", "🐹", "😸"]
    var audioPlayer: AVAudioPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 25/255, green: 23/255, blue: 68/255, alpha: 1.0)
        
        bgView = UIImageView(frame: self.view.bounds)
        bgView.center = self.view.center
        bgView.contentMode = .scaleAspectFill
        bgView.image = UIImage.gif(url: Constants.night)
        self.view.addSubview(bgView)
        
        dswitch = DUISwicth(view: self.bgView, color: UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1.0))
        dswitch.center = CGPoint(x: self.view.center.x, y: self.view.frame.height - 45)
        dswitch.addTarget(self, action: #selector(ViewController.switchChanged), for: .valueChanged)
        self.view.addSubview(dswitch)
        
        self.newBg = UIImageView(frame: self.view.bounds)
        self.newBg.image = UIImage.gif(url: Constants.day)
        self.newBg.contentMode = .scaleAspectFit
        
        dswitch.animationDidStartClosure = { [unowned self] _ in
            if !self.dswitch.isOn {
                UIView.animate(withDuration: 0.1, animations: {
                    self.newBg?.alpha = 0
                })
            }
        }
        
        dswitch.animationDidStopClosure = { [unowned self] _ in
            if self.dswitch.isOn {
                self.newBg.alpha = 1
                self.view.addSubview(self.newBg)
                self.view.bringSubview(toFront: self.dswitch)
            }else {
                self.newBg.removeFromSuperview()
            }
        }
        
        self.statusLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 30))
        self.statusLabel.textAlignment = .center
        self.statusLabel.font = UIFont.systemFont(ofSize: 12)
        self.statusLabel.center.y = dswitch.frame.origin.y - 20
        self.view.addSubview(statusLabel)
        
        register()
        
        if defaults.bool(forKey: Constants.switchKey) {
            self.dswitch.setOn(true, animated: true)
        }
        self.updateStatus()
        
        //Navbar
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "menu"), style: .plain, target: self, action: #selector(self.openMenu(sender:)))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        self.updateBarTint()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateStatus()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Handlers
    
    
    func openMenu(sender: AnyObject) {
        self.show(SettingsViewController(delegate: self), sender: self)
    }
    
    func switchChanged() {
        
        if dswitch.isOn {
            //Swicthed ON
            defaults.set(true, forKey: Constants.switchKey)
            self.scheduleNotifications()
        }else {
            //Switched OFF
            defaults.set(false, forKey: Constants.switchKey)
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
        self.setNeedsStatusBarAppearanceUpdate()
        self.updateBarTint()
        self.updateStatus()
        
    }
    
    //MARK: - Helpers
    
    func register() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay! 🙌🏼")
            } else {
                print("D'oh")
            }
        }
    }
    
    func scheduleNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Yo Dole " + emojis[Int(arc4random_uniform(UInt32(emojis.count)))]
        content.body = "Its time to sit straight 💁🏻"
        content.categoryIdentifier = "alarm"
        content.sound = UNNotificationSound.default()
        
        if defaults.bool(forKey: Constants.reminder) {
            for hr in 10...17 {
                let date = self.createDateComponent(hour: hr, minute: 50)
                let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                center.add(request)
            }
        } else {
            for startDay in 2...6 {
                for hr in 10...17 {
                    let date = self.createDateComponent(hour: hr, weekday: startDay)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    center.add(request)
                }
            }
        }

    }
    
    func createDateComponent(hour: Int, minute: Int = 0, weekday: Int? = nil) -> DateComponents {
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.weekday = weekday
        
        return dateComponents
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.dswitch.isOn {
            if audioPlayer != nil {
                audioPlayer.stop()
                audioPlayer = nil
                return
            }
            self.playSong()
        }
    }
    
    //MARK: - Update methods
    
    func updateBarTint() {
        if dswitch.isOn {
            self.navigationController?.navigationBar.tintColor = UIColor(red: 90/255, green: 147/255, blue: 192/255, alpha: 1.0)
        }else {
            self.navigationController?.navigationBar.tintColor = UIColor.white
        }
    }
    
    func updateStatus() {
        self.statusLabel.alpha = 0
        UIView.animate(withDuration: 1.2) {
            self.statusLabel.alpha = 1
        }
        if dswitch.isOn {
            var textToAppend = "on Weekdays"
            if defaults.bool(forKey: Constants.reminder) {
                textToAppend = "Everyday"
            }
            self.statusLabel.text = "Set to remind " + textToAppend
            self.statusLabel.textColor = UIColor(red: 90/255, green: 66/255, blue: 48/255, alpha: 1.0)
        }else {
            self.statusLabel.text = "Night mode enabled"
            self.statusLabel.textColor = UIColor(red: 203/255, green: 203/255, blue: 203/255, alpha: 1.0)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        guard let status = self.dswitch?.isOn else {
            return .lightContent
        }
        if status {
            return .default
        }else {
            return .lightContent
        }
    }
    
    //MARK: - SettingsDelegate
    
    func scheduleDidChange() {
        if self.dswitch.isOn {
            self.scheduleNotifications()
        }
    }
    
    //MARK: - AVPlayer
    
    func playSong() {
        if let path = Bundle.main.path(forResource: "happy.mp3", ofType:nil) {
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer.play()
                audioPlayer.delegate = self
            }catch {
                // couldn't load file :(
                print("Couldn't play song!")
            }
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.audioPlayer.stop()
        self.audioPlayer = nil
    }

}

