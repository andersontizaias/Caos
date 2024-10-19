import UIKit
import PlaygroundSupport

@available(iOS 13.0, *)
public class CaosView: UIView {
    
    let shardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 4, height: 4)
        view.layer.shadowOpacity = 0.25
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 120).isActive = true
        return view
    }()
    
    let shardLabel: UILabel = {
        let label = UILabel()
        label.text = "Minha Rede"
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let hStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution  = .equalCentering
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let cardViewSimulador: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.orange.cgColor
        view.layer.borderWidth = 0.25
        view.layer.cornerRadius = 15
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 4, height: 4)
        view.layer.shadowOpacity = 0.25
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        
        
        let label = UILabel()
        label.text = "Simulador"
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textColor = .orange
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        let imageView = UIImageView(image: UIImage(systemName: "iphone.gen3.circle"))
        imageView.tintColor = .orange
        imageView.sizeToFit()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 80),
            view.widthAnchor.constraint(equalToConstant: 80),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 40),
            imageView.widthAnchor.constraint(equalToConstant: 40),
        ])
        
        return view
    }()
    
    let cardViewPix: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.orange.cgColor
        view.layer.borderWidth = 0.25
        view.layer.cornerRadius = 15
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 4, height: 4)
        view.layer.shadowOpacity = 0.25
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Pix"
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textColor = .orange
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        let imageView = UIImageView(image: UIImage(systemName: "arrow.left.arrow.right.circle"))
        imageView.tintColor = .orange
        imageView.sizeToFit()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 80),
            view.widthAnchor.constraint(equalToConstant: 80),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 40),
            imageView.widthAnchor.constraint(equalToConstant: 40),
        ])
        
        return view
    }()
    
    let cardViewAnticipation: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.orange.cgColor
        view.layer.borderWidth = 0.25
        view.layer.cornerRadius = 15
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 4, height: 4)
        view.layer.shadowOpacity = 0.25
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Antecipação"
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textColor = .orange
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        let imageView = UIImageView(image: UIImage(systemName: "dollarsign.circle"))
        imageView.tintColor = .orange
        imageView.sizeToFit()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 80),
            view.widthAnchor.constraint(equalToConstant: 80),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 40),
            imageView.widthAnchor.constraint(equalToConstant: 40),
        ])
        
        return view
    }()
    
    let cardViewPCancellation: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.orange.cgColor
        view.layer.borderWidth = 0.25
        view.layer.cornerRadius = 15
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 4, height: 4)
        view.layer.shadowOpacity = 0.25
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Cancelamento"
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textColor = .orange
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        let imageView = UIImageView(image: UIImage(systemName: "iphone.gen3.slash.circle"))
        imageView.tintColor = .orange
        imageView.sizeToFit()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 80),
            view.widthAnchor.constraint(equalToConstant: 80),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 40),
            imageView.widthAnchor.constraint(equalToConstant: 40),
        ])
        
        return view
    }()
    
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemFill //MyCustomView.randomizeUIColor()
        shardView.addSubview(shardLabel)
        shardView.addSubview(hStackView)
        hStackView.addArrangedSubview(cardViewSimulador)
        hStackView.addArrangedSubview(cardViewPix)
        hStackView.addArrangedSubview(cardViewAnticipation)
        hStackView.addArrangedSubview(cardViewPCancellation)
        
        addSubview(shardView)
        
        NSLayoutConstraint.activate([
            
            self.heightAnchor.constraint(equalToConstant: 130),
            shardView.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 10),
            shardView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            shardView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            shardLabel.leadingAnchor.constraint(equalTo: shardView.leadingAnchor, constant: 10),
            shardLabel.topAnchor.constraint(equalTo: shardView.topAnchor, constant: 5),
            
            hStackView.leadingAnchor.constraint(equalTo: shardView.leadingAnchor, constant: 10),
            hStackView.topAnchor.constraint(equalTo: shardLabel.bottomAnchor, constant: 5),
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Função randomizeUIColor conforme seu código anterior.
    static func randomizeUIColor() -> UIColor {
        return UIColor(red: CGFloat.random(in: 0...1),
                       green: CGFloat.random(in: 0...1),
                       blue: CGFloat.random(in: 0...1),
                       alpha: 1.0)
    }
}

@available(iOS 13.0, *)
public class CaosViewCard: UIView {
    
    let shardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 4, height: 4)
        view.layer.shadowOpacity = 0.25
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 120).isActive = true
        return view
    }()
    
    let shardLabel: UILabel = {
        let label = UILabel()
        label.text = "Antecipação de recebiveis"
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let totalLabel: UILabel = {
        let label = UILabel()
        label.text = "Total disponível:"
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let totalValue: UILabel = {
        let label = UILabel()
        label.text = "R$10.000,00"
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "dollarsign.circle"))
        imageView.tintColor = .orange
        imageView.sizeToFit()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemFill //MyCustomView.randomizeUIColor()
        shardView.addSubview(shardLabel)
        shardView.addSubview(totalLabel)
        shardView.addSubview(totalValue)
        shardView.addSubview(imageView)
        addSubview(shardView)
        
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 130),
            shardView.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 10),
            shardView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            shardView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            shardLabel.leadingAnchor.constraint(equalTo: shardView.leadingAnchor, constant: 10),
            shardLabel.topAnchor.constraint(equalTo: shardView.topAnchor, constant: 5),
            totalLabel.centerYAnchor.constraint(equalTo: shardView.centerYAnchor),
            totalLabel.leadingAnchor.constraint(equalTo: shardView.leadingAnchor, constant: 85),
            totalValue.centerYAnchor.constraint(equalTo: shardView.centerYAnchor),
            totalValue.leadingAnchor.constraint(equalTo: totalLabel.trailingAnchor, constant: 5),
            imageView.leadingAnchor.constraint(equalTo: shardView.leadingAnchor, constant: 20),
            imageView.centerYAnchor.constraint(equalTo: shardView.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 60),
            imageView.widthAnchor.constraint(equalToConstant: 60),
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

@available(iOS 13.0, *)
public class CaosViewShortcuts: UIView {
    
    let shardLabel: UILabel = {
        let label = UILabel()
        label.text = "O que você quer fazer?"
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let cardViewPCancellation: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.orange.cgColor
        view.layer.borderWidth = 0.25
        view.layer.cornerRadius = 15
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 4, height: 4)
        view.layer.shadowOpacity = 0.25
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Cancelamento"
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .orange
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        let imageView = UIImageView(image: UIImage(systemName: "iphone.gen3.slash.circle"))
        imageView.tintColor = .orange
        imageView.sizeToFit()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 150),
            view.widthAnchor.constraint(equalToConstant: 150),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.widthAnchor.constraint(equalToConstant: 80),
        ])
        
        return view
    }()
    
    let cardViewPaymentLink: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.orange.cgColor
        view.layer.borderWidth = 0.25
        view.layer.cornerRadius = 15
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 4, height: 4)
        view.layer.shadowOpacity = 0.25
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Link de pagamento"
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .orange
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        let imageView = UIImageView(image: UIImage(systemName: "gobackward"))
        imageView.tintColor = .orange
        imageView.sizeToFit()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 150),
            view.widthAnchor.constraint(equalToConstant: 150),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.widthAnchor.constraint(equalToConstant: 80),
        ])
        
        return view
    }()
    
    let cardViewPSales: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.orange.cgColor
        view.layer.borderWidth = 0.25
        view.layer.cornerRadius = 15
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 4, height: 4)
        view.layer.shadowOpacity = 0.25
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Vendas"
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .orange
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        let imageView = UIImageView(image: UIImage(systemName: "checkmark.circle"))
        imageView.tintColor = .orange
        imageView.sizeToFit()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 150),
            view.widthAnchor.constraint(equalToConstant: 150),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.widthAnchor.constraint(equalToConstant: 80),
        ])
        
        return view
    }()
    
    let cardViewReceivavles: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.orange.cgColor
        view.layer.borderWidth = 0.25
        view.layer.cornerRadius = 15
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 4, height: 4)
        view.layer.shadowOpacity = 0.25
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Recebimentos"
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .orange
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        let imageView = UIImageView(image: UIImage(systemName: "flag.checkered.circle"))
        imageView.tintColor = .orange
        imageView.sizeToFit()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 150),
            view.widthAnchor.constraint(equalToConstant: 150),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.widthAnchor.constraint(equalToConstant: 80),
        ])
        
        return view
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemFill //MyCustomView.randomizeUIColor()
        addSubview(shardLabel)
        addSubview(cardViewPCancellation)
        addSubview(cardViewPaymentLink)
        addSubview(cardViewPSales)
        addSubview(cardViewReceivavles)
        
        
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 340),
            shardLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            shardLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            cardViewPCancellation.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25),
            cardViewPCancellation.topAnchor.constraint(equalTo: shardLabel.bottomAnchor, constant: 10),
            cardViewPaymentLink.leadingAnchor.constraint(equalTo: cardViewPCancellation.trailingAnchor, constant: 20),
            cardViewPaymentLink.topAnchor.constraint(equalTo: shardLabel.bottomAnchor, constant: 10),
            cardViewPSales.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25),
            cardViewPSales.topAnchor.constraint(equalTo: cardViewPCancellation.bottomAnchor, constant: 10),
            cardViewReceivavles.leadingAnchor.constraint(equalTo: cardViewPSales.trailingAnchor, constant: 20),
            cardViewReceivavles.topAnchor.constraint(equalTo: cardViewPaymentLink.bottomAnchor, constant: 10),
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


// Simular iPhone 8
let simulatedScreenSize = CGRect(x: 0, y: 0, width: 375, height: 600)


PlaygroundPage.current.liveView = CaosViewShortcuts(frame: simulatedScreenSize)

