//
//  CaosEngine.swift
//  Caos
//
//  Created by Anderson Tiago Izaias on 08/10/23.
//

import Foundation


public class CaosEngine {
    
    // MARK: - Properties

    public weak var delegate: CaosEngineDelegate?
    public private(set) var store: CaosStore?
    private var scrollViews: [UIScrollView] = []

    // MARK: - Initializers

    public init(content: String, target: CaosEngineDelegate, store: CaosStore? = nil) {
        self.delegate = target
        self.store = store
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
    
    private func setupScrollViews(screen: CaosScreen) {
        let stackView = screen.containerConfig.type.contains("vertical")
            ? createVerticalStackView()
            : createHorizontalStackView()
        if screen.containerConfig.spacing > 0 {
            stackView.spacing = screen.containerConfig.spacing
        }
        let scrollView = createScrollView(stackView: stackView)
        scrollViews.append(scrollView)
    }

    private func setupShards(screen: CaosScreen) {
        let shards: [CaosShard] = screen.shardList.isEmpty
            ? screen.shards.map { CaosShard(type: $0) }
            : screen.shardList

        for shard in shards {
            if let shardView: CaosView = createShardView(className: shard.type) {
                shardView.delegate = delegate
                shardView.configure(with: shard.props)
                if let stackView = scrollViews.last?.subviews.first as? UIStackView {
                    stackView.addArrangedSubview(shardView)
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
