//
//  SecondViewController.swift
//  VocabularyLearningApp
//
//  Created by Yusuf Özgül on 23.04.2019.
//  Copyright © 2019 Yusuf Özgül. All rights reserved.
//

import UIKit

class TestVC: UIViewController, WordScrollViewProtocol
{
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var levelView: UIView!
    let wordPageScrollView: UIScrollView = UIScrollView() // kaydırılabilir sayfamız
    var blurredEffectView = UIVisualEffectView() // loading view'u
    let loadingIndicator = UIActivityIndicatorView()
    let wordDataParser = TestWordParser.parser // Api'daki kelimeyi işleyip veren static sınıf
    var wordDataArray: [WordTestPageData] = [] // sayfalardaki verilerimiz
    let messageService: MessageViewerProtocol = MessageViewer.messageViewer
    
    var wordPages: [WordPage] = { () -> [WordPage] in // ScrollView sayfalarının oluşturulmasu
        let wordPage0: WordPage = Bundle.main.loadNibNamed("WordPage", owner: self, options: nil)?.first as! WordPage // Previous Page
        let wordPage1: WordPage = Bundle.main.loadNibNamed("WordPage", owner: self, options: nil)?.first as! WordPage // Current Page
        let wordPage2: WordPage = Bundle.main.loadNibNamed("WordPage", owner: self, options: nil)?.first as! WordPage // Next Page
        return [wordPage0, wordPage1, wordPage2] }()
    
    var isDragging = false // kaydırma kontrolü
    var scrollViewSize: CGSize = .zero
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
//        View ayarlamaları
        navigationItem.title = NSLocalizedString("TEST_VC_TITLE", comment: "")
        wordPageScrollView.delegate = self
        wordPageScrollView.isPagingEnabled = true
        wordPageScrollView.showsHorizontalScrollIndicator = false
        wordPageScrollView.showsVerticalScrollIndicator = false
        view.addSubview(wordPageScrollView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(levelMessage))
        levelView.addGestureRecognizer(tapGesture)
        
//        Kelime geldiği zaman bilgi mesajını yakalayıp işlem yapımı
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "FetchTestWords"), object: nil, queue: OperationQueue.main, using: { _ in
            if self.wordDataParser.learnWordService.getLearnArrayCount() > 0
            { self.prepareScrollView() }
            self.loadingView()
        })
    }
    override func viewWillAppear(_ animated: Bool)
    {
//        Verilerin çekilmesi, parse edilmesi ve local verilerin çekilmesi
        wordDataParser.fetchedTestWord()
        loadingView()
    }
    internal func loadingView() // Loading sayfası gösterimi ve kontrolü
    {
        if wordDataParser.getTestArrayCount() == 0
        {
            let blurEffect = UIBlurEffect(style: .extraLight)
            blurredEffectView.effect = blurEffect
            blurredEffectView.frame = view.frame
            loadingIndicator.style = .whiteLarge
            loadingIndicator.color = .black
            loadingIndicator.center = view.center
            loadingIndicator.startAnimating()
            blurredEffectView.contentView.addSubview(loadingIndicator)
            view.addSubview(blurredEffectView)
        }
        else
        {
            blurredEffectView.removeFromSuperview() // Kelime varsa Loading ekranı view'dan siliniyor.
        }
    }
    @objc func levelMessage()
    {
        messageService.infoView(title: NSLocalizedString("LEVEL_INFO", comment: ""), body: NSLocalizedString("LEVEL_INFO_DESC", comment: ""))
    }
    internal func prepareScrollView() // ScrollView'un ayarlanması ve kelimelerin yerleştirilmesi
    {
        var wordData = wordDataParser.getTestWord()
        for page in wordPages
        {
            page.frame.size.width = view.frame.width / 1.2
            page.frame.size.height = view.frame.height / 1.5
        }
        wordDataArray.removeAll()
        
        for i in 0 ..< 3 // üç sayfada ayrı ayrı oluşturuluyor.
        {
            wordData = wordDataParser.getTestWord()
            wordDataArray.append(wordData)
            wordPageScrollView.addSubview(wordPages[i])
        }
        scrollViewSize = (wordPages.first?.frame.size)!
        wordPageScrollView.frame.size = scrollViewSize
        wordPageScrollView.center = CGPoint(x: view.frame.size.width  / 2, y: view.frame.size.height / 2)
        wordPageScrollView.contentSize = CGSize(width: scrollViewSize.width * 3, height: scrollViewSize.height)
        wordPageScrollView.contentOffset = CGPoint(x: scrollViewSize.width, y: 0)
        layoutWordPage()
    }
    internal func layoutWordPage() // ScrollView'a kelimelerin verilmesi
    {
        var index = 0
        for page in wordPages
        {
            let wordData = wordDataArray[index]
            page.delegate = self
            
//            Sayfaların oluşturulmasında varsayılan ayarları yapılıyorç
            page.answerBox1Image.image = UIImage(named: "BoxBackground")
            page.answerBox2Image.image = UIImage(named: "BoxBackground")
            page.answerBox3Image.image = UIImage(named: "BoxBackground")
            page.answerBox4Image.image = UIImage(named: "BoxBackground")
            
//            Kelimeleri ve şıkları yerleştirme
            page.wordLabel.text = wordData.wordPage.wordInfo.word
            page.wordCategoryLabel.text = wordData.wordPage.wordInfo.category
            page.wordSentence.text = wordData.wordPage.wordInfo.sentence
            
            page.answerBox1Label.text = wordData.wordPage.option1
            page.answerBox2Label.text = wordData.wordPage.option2
            page.answerBox3Label.text = wordData.wordPage.option3
            page.answerBox4Label.text = wordData.wordPage.option4
            
            page.frame = CGRect(x: wordPageScrollView.frame.width * CGFloat(index),
                                y: 0,
                                width: wordPageScrollView.frame.width,
                                height: wordPageScrollView.frame.height)
            index += 1
        }
        levelLabel.text = String(wordDataArray[1].level)
    }
}
