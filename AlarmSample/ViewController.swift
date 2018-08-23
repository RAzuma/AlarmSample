//
//  ViewController.swift
//  AlarmSample
//
//  Created by Ryohei Azuma on 2018/08/23.
//  Copyright © 2018年 Ryohei Azuma. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var setTime: UILabel!
    
    private var walkTimer: Timer?
    private var audioPlayer: AVAudioPlayer?
    
    private var silentMusicPlayer: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setTime.text = ""
        
        // タイマーが止まらないかを確認する
        // バックグラウンドでもなるのか確認
        // ロック画面でもなるのか確認
        
        // 無音をループさせる処理（バックグラウンド処理のため）
        self.silentMusicPlayer = try? AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "background", withExtension: "wav")!)
        self.silentMusicPlayer?.volume = 0
        self.silentMusicPlayer?.numberOfLoops = -1 // -1で無限ループ
        self.silentMusicPlayer?.play()
        
        // アラーム音の準備
        // ライセンス表記する
        // http://musicisvfr.com/free/se/clock01.html
        // 素材提供：Music is VFR(http://musicisvfr.com/)
        self.audioPlayer = try? AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "alarm", withExtension: "mp3")!)
        self.audioPlayer?.volume = 0.7
        self.audioPlayer?.numberOfLoops = 20 // 5分くらいになるように調整
        self.audioPlayer?.prepareToPlay()
        
    }
    
    // 音を鳴らす
    @objc func musicStart() {
        self.audioPlayer?.play()
    }
    
    @IBAction func wakeUpAction(_ sender: UIButton) {
        
        // 音を止める
        self.audioPlayer?.stop()
    }
    
    @IBAction func beingLateAction(_ sender: UIButton) {
        
        // 音を止める
        self.audioPlayer?.stop()
        
        // 連携が割とめんどくさそう・・・・
        // 遅刻処理　文字列
        // メール
        // twitter
        // slack
        // chatwork
        
    }
    
    @IBAction func setAlarmAction(_ sender: UIButton) {
        
        // 時間チェック
        let pattern = "([0-1][0-9]|2[0-3]):[0-5][0-9]"
        
        let regex = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options(rawValue: 0))
        let matches = regex.matches(in: setTime.text!, options: [], range: NSMakeRange(0, setTime.text!.count))
        
        if matches.count == 0 {
            setTime.text = ""
            return
        }
        
        // 時間を比較して明日か今日なのか
        let date = dateToStringHM(input: Date())
        var alarmDate:Date!
        var input:String!
        
        if date > setTime.text! {
            input = dateToStringYMD(input: Date().addingTimeInterval(86400))
        } else {
            input = dateToStringYMD(input: Date())
        }
        
        alarmDate = stringToDate(input: input + " " + setTime.text!)
        
        // タイマー処理
        walkTimer = Timer.scheduledTimer(timeInterval: alarmDate.timeIntervalSince(Date()), target: self, selector: #selector(musicStart), userInfo: nil, repeats: false)
        
        // タイマーセットされているときの色
        setTime.textColor = UIColor.red
        
    }
    
    @IBAction func setTimeAction(_ sender: UIButton) {
        
        if setTime.text!.count > 4 {
            return
        }
        
        if setTime.text!.count == 2 {
            setTime.text! += ":"
            setTime.text! += sender.tag.description
        } else {
            setTime.text! += sender.tag.description
        }
        
    }
    
    @IBAction func clearTimeAction(_ sender: UIButton) {
        setTime.text! = ""
        setTime.textColor = UIColor.black
        
        walkTimer?.invalidate()
    }
    
    private func dateToStringYMD(input:Date)->String{
        
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd"
        
        return dateFormater.string(from: input)
        
    }
    
    private func dateToStringHM(input:Date)->String{
        
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "HH:mm"
        
        return dateFormater.string(from: input)
        
    }
    
    private func stringToDate(input:String)->Date{
        
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd HH:mm"
        
        return dateFormater.date(from: input)!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

