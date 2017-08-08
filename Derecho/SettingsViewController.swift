//
//  SettingsViewController.swift
//  Derecho
//
//  Created by Niranjan Ravichandran on 8/4/17.
//  Copyright © 2017 Aviato. All rights reserved.
//

import UIKit

protocol SettingsDelegate {
    func scheduleDidChange()
}

class SettingsViewController: UIViewController {
    
    var minionBG: UIImageView!
    var weekdayButton: AIFlatSwitch!
    var everydayButton: AIFlatSwitch!
    
    let defaults = UserDefaults.standard
    
    var delegate: SettingsDelegate?
    
    
    convenience init(delegate: SettingsDelegate) {
        self.init()
        self.delegate = delegate
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 244/255, green: 245/255, blue: 254/255, alpha: 1.0)
        minionBG = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height/2))
        minionBG.frame.origin.y -= minionBG.frame.height
        minionBG.contentMode = .scaleAspectFit
        let backgroundQueue = DispatchQueue(label: "com.aviato.queue", qos: .background, attributes: [.concurrent], autoreleaseFrequency: .inherit, target: nil)
        backgroundQueue.async {
            self.minionBG.image = UIImage.gif(url: Constants.minion)
        }
        self.view.addSubview(minionBG)
        
        let info = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 25))
        info.text = "Choose your settings"
        info.textColor = UIColor(red: 1/255, green: 52/255, blue: 85/255, alpha: 0.8)
        info.center = self.view.center
        info.center.y += 15
        info.textAlignment = .center
        self.view.addSubview(info)
        
        let weekdayView = UIControl(frame: CGRect(x: 0, y: 0, width: 120, height: 35))
        weekdayView.center = self.view.center
        weekdayView.center.y += 60
        weekdayView.center.x -= weekdayView.frame.width - 40
        weekdayView.backgroundColor = UIColor(red: 90/255, green: 147/255, blue: 192/255, alpha: 1.0)
        weekdayButton = AIFlatSwitch(frame: CGRect(x: 8, y: 0, width: 20, height: 20))
        weekdayButton.lineWidth = 2.0
        weekdayButton.strokeColor = UIColor.white
        weekdayButton.center.y = weekdayView.frame.height/2
        weekdayButton.animatesOnTouch = true
        weekdayButton.trailStrokeColor = UIColor.white
        weekdayButton.isUserInteractionEnabled = false
        weekdayView.addSubview(weekdayButton)
        let weekLabel = UILabel(frame: CGRect(x: 35, y: 0, width: weekdayView.frame.width - 40, height: 35))
        weekLabel.textColor = UIColor.white
        weekLabel.text = "Weekdays"
        weekdayView.addSubview(weekLabel)
        weekdayView.layer.cornerRadius = 6
        weekdayView.tag = 100
        weekdayView.addTarget(self, action: #selector(SettingsViewController.buttonDown(sender:)), for: .touchDown)
        weekdayView.addTarget(self, action: #selector(SettingsViewController.buttonTapped(sender:)), for: .touchUpInside)
        self.view.addSubview(weekdayView)
        
        let everydayView = UIControl(frame: CGRect(x: 0, y: 0, width: 120, height: 35))
        everydayView.center = self.view.center
        everydayView.center.y += 60
        everydayView.center.x += everydayView.frame.width - 40
        everydayView.backgroundColor = UIColor(red: 90/255, green: 147/255, blue: 192/255, alpha: 1.0)
        everydayButton = AIFlatSwitch(frame: CGRect(x: 8, y: 0, width: 20, height: 20))
        everydayButton.lineWidth = 2.0
        everydayButton.strokeColor = UIColor.white
        everydayButton.center.y = everydayView.frame.height/2
        everydayButton.animatesOnTouch = true
        everydayButton.trailStrokeColor = UIColor.white
        everydayButton.isSelected = false
        everydayButton.isUserInteractionEnabled = false
        everydayView.addSubview(everydayButton)
        let everydayLabel = UILabel(frame: CGRect(x: 35, y: 0, width: everydayView.frame.width - 40, height: 35))
        everydayLabel.textColor = UIColor.white
        everydayLabel.text = "Everyday"
        everydayView.addSubview(everydayLabel)
        everydayView.layer.cornerRadius = 6
        everydayView.tag = 101
        everydayView.addTarget(self, action: #selector(SettingsViewController.buttonDown(sender:)), for: .touchDown)
        everydayView.addTarget(self, action: #selector(SettingsViewController.buttonTapped(sender:)), for: .touchUpInside)
        self.view.addSubview(everydayView)
        
        let descLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width - 35, height: 0))
        descLabel.font = UIFont.systemFont(ofSize: 10)
        descLabel.textAlignment = .center
        descLabel.numberOfLines = 0
        descLabel.lineBreakMode = .byWordWrapping
        descLabel.text = "When enabled you will receive reminders once every hour from 10 a.m to 5 p.m."
        descLabel.sizeToFit()
        descLabel.textColor = UIColor(red: 1/255, green: 52/255, blue: 85/255, alpha: 0.6)
        descLabel.center.x = self.view.center.x
        descLabel.frame.origin.y = everydayView.frame.origin.y + everydayView.frame.height + 12
        self.view.addSubview(descLabel)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(SettingsViewController.back))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintColor = UIColor(red: 90/255, green: 147/255, blue: 192/255, alpha: 1.0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.4) {
            self.minionBG.frame.origin.y = 20
        }
        if  defaults.bool(forKey: Constants.reminder) {
            everydayButton.setSelected(true, animated: true)
        }else {
            weekdayButton.setSelected(true, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func buttonTapped(sender: UIControl) {
        //Button animation
        sender.alpha = 0.5
        UIView.animate(withDuration: 0.3) { 
            sender.alpha = 1
        }
        
        if sender.tag == 100 {
            if !weekdayButton.isSelected {
                weekdayButton.setSelected(true, animated: true)
                everydayButton.setSelected(false, animated: false)
                defaults.set(false, forKey: Constants.reminder)
            }
        }else {
            if !everydayButton.isSelected {
                everydayButton.setSelected(true, animated: true)
                weekdayButton.setSelected(false, animated: false)
                defaults.set(true, forKey: Constants.reminder)
            }
        }
        
        self.delegate?.scheduleDidChange()
    }
    
    func buttonDown(sender: UIControl) {
        sender.alpha = 0.5
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

}
