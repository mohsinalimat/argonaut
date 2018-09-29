import CleanArchitecture
import MarkdownHero

class MakeView:View<MakePresenter> {
    private weak var progress:UIProgressView!
    private let parser = Parser()
    override var preferredStatusBarStyle:UIStatusBarStyle { return .lightContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        makeOutlets()
        configureViewModel()
    }
    
    private func makeOutlets() {
        let load = LoadingView()
        load.tintColor = .white
        view.addSubview(load)
        
        let label = UILabel()
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize:14, weight:.light)
        label.textColor = .white
        label.numberOfLines = 0
        view.addSubview(label)
        parser.parse(string:.localized("MakeView.label")) { [weak label] string in label?.attributedText = string }
        
        let cancel = UIButton()
        cancel.translatesAutoresizingMaskIntoConstraints = false
        cancel.setTitle(.localized("MakeView.cancel"), for:[])
        cancel.setTitleColor(UIColor(white:1, alpha:0.6), for:.normal)
        cancel.setTitleColor(UIColor(white:1, alpha:0.2), for:.highlighted)
        cancel.titleLabel!.font = .systemFont(ofSize:16, weight:.regular)
        cancel.addTarget(presenter, action:#selector(presenter.cancel), for:.touchUpInside)
        view.addSubview(cancel)
        
        let progress = UIProgressView()
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.trackTintColor = UIColor(white:1, alpha:0.1)
        progress.progressTintColor = .white
        progress.isUserInteractionEnabled = false
        view.addSubview(progress)
        self.progress = progress
        
        load.centerXAnchor.constraint(equalTo:view.centerXAnchor).isActive = true
        load.centerYAnchor.constraint(equalTo:view.centerYAnchor).isActive = true
        
        label.centerXAnchor.constraint(equalTo:view.centerXAnchor).isActive = true
        
        cancel.heightAnchor.constraint(equalToConstant:50).isActive = true
        cancel.widthAnchor.constraint(equalToConstant:120).isActive = true
        cancel.centerXAnchor.constraint(equalTo:view.centerXAnchor).isActive = true
        
        progress.bottomAnchor.constraint(equalTo:view.bottomAnchor).isActive = true
        progress.leftAnchor.constraint(equalTo:view.leftAnchor).isActive = true
        progress.rightAnchor.constraint(equalTo:view.rightAnchor).isActive = true
        progress.heightAnchor.constraint(equalToConstant:10).isActive = true
        
        if #available(iOS 11.0, *) {
            label.topAnchor.constraint(equalTo:view.safeAreaLayoutGuide.topAnchor, constant:20).isActive = true
            cancel.bottomAnchor.constraint(equalTo:view.safeAreaLayoutGuide.bottomAnchor, constant:-50).isActive = true
        } else {
            label.topAnchor.constraint(equalTo:view.topAnchor, constant:20).isActive = true
            cancel.bottomAnchor.constraint(equalTo:view.bottomAnchor, constant:-50).isActive = true
        }
    }
    
    private func configureViewModel() {
        presenter.viewModel { [weak self] (progress:Float) in
            self?.progress.setProgress(progress, animated:true)
        }
    }
}
