import UIKit

extension UITableView {
    
    func register(_ cellClass: AnyClass) {
        self.register(cellClass, forCellReuseIdentifier: cellReuseIdentifier(for: cellClass))
    }
    
    func dequeueCell<CellClass: UITableViewCell>(for indexPath: IndexPath) -> CellClass? {
        return dequeueReusableCell(
            withIdentifier: cellReuseIdentifier(for: CellClass.self),
            for: indexPath
        ) as? CellClass
    }
 
    func cellReuseIdentifier(for cellClass: AnyClass) -> String {
        "\(cellClass)"
    }
    
}

