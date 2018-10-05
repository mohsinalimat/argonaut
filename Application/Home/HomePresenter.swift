import CleanArchitecture
import Argonaut
import MarkdownHero

class HomePresenter:Presenter {
    private let map = Map()
    private let session = Factory.makeSession()
    private let parser = Parser()
    private let formatter = DateComponentsFormatter()
    
    @objc func planMap() {
        Application.navigation.pushViewController(PlanView(), animated:true)
    }
    
    @objc func open(cell:HomeCellView) {
        let view = TravelView()
        view.presenter.project = cell.viewModel.project
        Application.navigation.setViewControllers([view], animated:true)
    }
    
    @objc func settings() {
        Application.navigation.setViewControllers([SettingsView()], animated:true)
    }
    
    override func didLoad() {
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.minute, .hour]
    }
    
    override func didAppear() { session.load { [weak self] (projects:[Project]) in self?.loaded(projects:projects) } }
    
    private func makeTitle(project:Project) -> NSAttributedString {
        var string = "**\(project.name)**\n"
        string += formatter.string(from:project.duration)!
        if #available(iOS 10.0, *) {
            let distance = MeasurementFormatter()
            distance.unitStyle = .medium
            distance.unitOptions = .naturalScale
            distance.numberFormatter.maximumFractionDigits = 1
            string += " - " + distance.string(from:Measurement(value:project.distance, unit:UnitLength.meters))
        }
        return parser.parse(string:string)
    }
    
    private func loaded(projects:[Project]) {
        let items = projects.map { project -> HomeItem in
            var item = HomeItem()
            item.title = makeTitle(project:project)
            item.project = project
            return item
        }
        update(viewModel:items)
        DispatchQueue.global(qos:.background).async { [weak self] in self?.map.cleanDisk() }
    }
}
