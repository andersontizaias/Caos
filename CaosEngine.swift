//
//  CaosEngine.swift
//  Caos
//
//  Created by Anderson Tiago Izaias on 08/10/23.
//

import Foundation


public class CaosEngine {
    
    //MARK: - Properties
    
    public weak var delegate: CaosEngineDelegate?
    private var scrollViews: [UIScrollView] = []
    
    //MARK: - Initializer
    
    init(content: String, target: CaosEngineDelegate) {
        
        delegate = target
        let caosParser = CaosParser(content: content)
        self.engine(parse: caosParser)
            
    }
    
    //MARK: - Public methods
    
    public func getScreenByIndex(index: Int) -> UIView {
        return scrollViews[index]
    }
    
    
    // MARK: - Private methods
    
    private func engine(parse: CaosParser){
        setupScreens(screens: parse.getScreens())
    }
    
    private func createVerticalStackView() -> UIStackView {
        
        let verticalStackView = UIStackView()
        verticalStackView.axis = .vertical
        verticalStackView.distribution = .fillProportionally
        verticalStackView.alignment = .fill
        verticalStackView.spacing = 0
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
    
        return verticalStackView
        
    }
    
    private func createHorizontalStackView() -> UIStackView {
        
        let horizontalStackView = UIStackView()
        horizontalStackView.axis = .horizontal
        horizontalStackView.distribution = .fillEqually
        horizontalStackView.alignment = .fill
        horizontalStackView.spacing = 0
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        return horizontalStackView
        
    }
    
    private func createShardView<T: UIView>(className: String) -> T? {
        guard let classType = NSClassFromString(className) as? T.Type else {
            print("Class not found or not of type UIView: \(className)")
            return nil
        }
        
        let shardViewInstance = classType.init()
        shardViewInstance.translatesAutoresizingMaskIntoConstraints = false
        
        return shardViewInstance
    }

    
    
    private func createScrollView(stackView: UIStackView)  -> UIScrollView{
            
            let scrollView = UIScrollView()
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(stackView)
            
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
            ])
        
            return scrollView
            
           
    }
    
    private func randomizeUIColor() -> UIColor {
        return UIColor(red: CGFloat.random(in: 0...1),
                       green: CGFloat.random(in: 0...1),
                       blue: CGFloat.random(in: 0...1),
                       alpha: 1.0)
    }
    
    
    private func setupScrollViews(screen: CaosScreen) {
        
        var scrollView: UIScrollView?
        
        if screen.container.contains("vertical") {
            
            let vStackView = createVerticalStackView()
            scrollView = createScrollView(stackView: vStackView)
        
        } else {
            
            let hStacView = createHorizontalStackView()
            scrollView = createScrollView(stackView: hStacView)
            
        }
        
        if let scrollView = scrollView {
            scrollViews.append(scrollView)
        }
    }
    
    private func setupShards(screen: CaosScreen) {
        let shards = screen.shards
        
        if shards.count > 0 {
            
            for shard in shards {
                if let shardView: CaosView = createShardView(className: shard) as? CaosView {
                    shardView.delegate = delegate
                    if let stackView = scrollViews.last?.subviews.first as? UIStackView {
                        stackView.addArrangedSubview(shardView)
                    }
                }
            }
        }
    }
    
    private func setupScreens(screens:[CaosScreen]) {
        if screens.count > 0 {
            for screen in screens {
                setupScrollViews(screen: screen)
                setupShards(screen: screen)
            }
        }
    }
    
}
