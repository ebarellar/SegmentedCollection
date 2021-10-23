//
//  SegmedtedCollection.swift
//  SegmentedCollection
//
//  Created by Trabajo on 24/09/21.
//

import UIKit

protocol SegmentedControlDelegate:AnyObject{
    func selectedSegment(number:Int)
    func attemptedToSelectLockedSegment(number:Int)
}

class SegmentedCollection: UIControl {
    weak var delegate:SegmentedControlDelegate? = nil
    
    var segmentBackground:UIColor? = .systemBlue
    
    var segmentTint:UIColor? = .white
    
    var selectedSegment:Int?{
        return self.collectionView.indexPathsForSelectedItems?.first?.row
    }
    
    private var collectionView:UICollectionView!
    private var leftIndicator:UIImageView!
    private var rightIndicator:UIImageView!
    private var animatedSelectionView:SegmentSelectedBackground!
    private let reuseIdentifier:String = "Segment"
    
    let itemWidth:CGFloat = 120.0
    let indicatorWidth:CGFloat = 12.0
    let animationDuration:CGFloat = 0.3
    
    var segments:[SelectableSegment] = [.init(title: "Segment 1"),
                                        .init(title: "Segment 2"),
                                        .init(title: "Segment 3", locked: true),
                                        .init(title: "Segment 4 Segment 4"),
                                        .init(title: "Segment 5")]
    {
                                    
        didSet{
            self.updateDataSource()
        }
    }
    
    lazy var dataSource:UICollectionViewDiffableDataSource<SegmentedSection,SelectableSegment> = configureDatsSource()
    
    private var fullWidth:Bool = false
    
    convenience init(segments:[SelectableSegment]){
        self.init(frame: .zero)
        self.segments = segments
        
        self.backgroundColor = segmentBackground
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = 8.0
        self.layer.masksToBounds = true
        
        self.backgroundColor = segmentBackground
        setCollectionView()
        
        setIndicators()
        
        setAnimatedSelection()
        
        if !self.segments.isEmpty{
            DispatchQueue.main.async {
                self.collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .left)
            }
        }
      
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSelected(_ index:Int, animated:Bool){
        let selectedIndex:IndexPath? = self.collectionView.indexPathsForSelectedItems?.first
        if selectedIndex?.row != index{
            self.collectionView.selectItem(at: IndexPath(row: index, section: 0),
                                           animated: animated, scrollPosition: .left)
        }
    }
    
    private func setAnimatedSelection(){
        //Hay que tener cuidado que la vista animada y la de la celda se parezcan
        
        self.animatedSelectionView = SegmentSelectedBackground()
        self.animatedSelectionView.frame = CGRect(origin: .zero,
                                                  size: CGSize(width: 1.0,
                                                               height: 4.0))
        self.animatedSelectionView.isHidden = true
        self.animatedSelectionView.isOpaque = false
        self.animatedSelectionView.backgroundShape.fillColor = self.segmentTint?.cgColor
        
        self.insertSubview(self.animatedSelectionView,
                           belowSubview: self.collectionView)
        
    }
    
    private func setIndicators(){
        leftIndicator = UIImageView(image: UIImage(systemName: "chevron.left"))
        leftIndicator.translatesAutoresizingMaskIntoConstraints = false
        leftIndicator.contentMode = .scaleAspectFit
        leftIndicator.tintColor = .black
        self.addSubview(leftIndicator)
        leftIndicator.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        leftIndicator.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        leftIndicator.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        leftIndicator.widthAnchor.constraint(equalToConstant: self.indicatorWidth).isActive = true
        
        rightIndicator = UIImageView(image: UIImage(systemName: "chevron.right"))
        rightIndicator.translatesAutoresizingMaskIntoConstraints = false
        rightIndicator.contentMode = .scaleAspectFit
        rightIndicator.tintColor = .black
        self.addSubview(rightIndicator)
        rightIndicator.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        rightIndicator.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        rightIndicator.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        rightIndicator.widthAnchor.constraint(equalToConstant: self.indicatorWidth).isActive = true
    }
    
    private func setCollectionView(){
        
        collectionView = UICollectionView(frame: self.bounds,
                                          collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        
        collectionView.register(UINib(nibName: "SegmentCollectionCell", bundle: nil),
                                forCellWithReuseIdentifier: self.reuseIdentifier)
        
        collectionView.fixInView(self)
        
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        collectionView.showsHorizontalScrollIndicator = false
        
        collectionView.dataSource = dataSource
        
        collectionView.delegate = self
        
        
        updateDataSource(animating: false)
    }
    
    private func updateDataSource(animating:Bool = true){
        var snapshot:NSDiffableDataSourceSnapshot<SegmentedSection,SelectableSegment> = .init()
        
        snapshot.appendSections([.all])
        snapshot.appendItems(self.segments, toSection: .all)
        
        dataSource.apply(snapshot, animatingDifferences: animating)
        
    }
    
    private func createLayout()->UICollectionViewLayout{
        
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = .horizontal
        
        let provider:UICollectionViewCompositionalLayoutSectionProvider = {
            (index, env) in
         
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let widthDimension:NSCollectionLayoutDimension
            let containerWidth = env.container.effectiveContentSize.width
            let itemsWidth = CGFloat(self.segments.count) * self.itemWidth
            
            self.fullWidth = itemsWidth <= containerWidth
            widthDimension = self.fullWidth ? .fractionalWidth(1.0/CGFloat((self.segments.count))):.absolute(self.itemWidth)
            
            self.collectionView.bounces = !self.fullWidth
            
            let realItemWidth:CGFloat = self.fullWidth ? (containerWidth / CGFloat(self.segments.count)):self.itemWidth
            self.animatedSelectionView.frame.size = CGSize(width: realItemWidth,
                                                           height: self.bounds.height)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension,
                                                   heightDimension: .fractionalHeight(1.0))
            
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item,
            count: 1)
            
            let section = NSCollectionLayoutSection(group: group)
            
//            let inset:CGFloat = self.fullWidth ? 0 :self.indicatorWidth / 2.0
//            section.contentInsets = .init(top: 0, leading: inset,
//                                          bottom: 0, trailing: inset)
            
            section.visibleItemsInvalidationHandler = {
                (items, offset, environment) in
                
                if self.fullWidth{
                    self.leftIndicator.isHidden = true
                    self.rightIndicator.isHidden = true
                }
                else{
                    var leftIsHidden:Bool = false
                    var rightIsHidden:Bool = false
                    for item in items{
                        if item.indexPath.row == 0{
                            if offset.x <= 0{
                                leftIsHidden = true
                            }
                        }
                        if item.indexPath.row == (self.segments.count - 1){
                            let containerWidth = env.container.effectiveContentSize.width
                            let translatedX = item.frame.maxX - offset.x
                            if translatedX <= containerWidth{
                                rightIsHidden = true
                            }
                        }
                    }
                    
                    self.leftIndicator.isHidden = leftIsHidden
                    self.rightIndicator.isHidden = rightIsHidden
                }
                
               
            }
            
            return section
            
        }
        
        return UICollectionViewCompositionalLayout(sectionProvider: provider,
                                                   configuration: config)
        
        
    }
    
    private func configureDatsSource()->UICollectionViewDiffableDataSource<SegmentedSection,SelectableSegment>{
        
        let dataSource = UICollectionViewDiffableDataSource<SegmentedSection,SelectableSegment>(collectionView: self.collectionView){
            (collectionView, indexPath, segment) in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseIdentifier, for: indexPath) as! SegmentCollectionCell
            
            cell.segmentTitle.text = segment.title
            cell.segmentBackground = self.segmentBackground
            cell.segmentTint = self.segmentTint
            cell.checkSelected()
            cell.isLocked = segment.locked
            
//            let items = collectionView.numberOfItems(inSection: indexPath.section)
//            cell.includeSeparator = indexPath.row < (items - 1)
            
            return cell
        }
        
        return dataSource
    }
}

extension SegmentedCollection:UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let currentSelection = self.collectionView.indexPathsForSelectedItems?.first,
              currentSelection.row != indexPath.row
        else {return false}
        
        if let segment = dataSource.itemIdentifier(for: indexPath),
           segment.locked{
            self.delegate?.attemptedToSelectLockedSegment(number: indexPath.row)
            return false
        }
        
        selectSegment(from: currentSelection, to: indexPath)
        
        return false
    }
    
    private func selectSegment(from:IndexPath, to:IndexPath){
        guard let toCell = self.collectionView.cellForItem(at: to) else{
            //Algo salio mal, seleccionar inmediatamente
            self.collectionView.selectItem(at: to, animated: false, scrollPosition: [])
            return
        }
        self.collectionView.deselectItem(at: from, animated: false)
        
        var fromCell:UICollectionViewCell? = nil
        for index in self.collectionView.indexPathsForVisibleItems{
            if index == from,
               let cell = self.collectionView.cellForItem(at: index){
                self.animatedSelectionView.center.x = cell.center.x - self.collectionView.contentOffset.x
                fromCell = cell
                break
            }
        }
        
        if fromCell == nil{
            if to.row > from.row{
                //Poner en izquierda
                self.animatedSelectionView.frame.origin.x = 0 - self.animatedSelectionView.frame.width
            }
            else{
                //Poner en derecha
                self.animatedSelectionView.frame.origin.x = self.bounds.width
            }
        }
        
        let destination = toCell.center.x - self.collectionView.contentOffset.x
        
        self.animatedSelectionView.isHidden = false
        self.isUserInteractionEnabled = false
        
        //Mueve la vista animada de seleccion
        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut) {
            self.animatedSelectionView.center.x = destination
        } completion: { success in
            self.collectionView.selectItem(at: to, animated: false, scrollPosition: [])
            self.animatedSelectionView.isHidden = true
            self.isUserInteractionEnabled = true
            self.delegate?.selectedSegment(number: to.row)
        }
        
        let toSegment:SegmentCollectionCell? = toCell as? SegmentCollectionCell
        let fromSegment:SegmentCollectionCell? = fromCell as? SegmentCollectionCell
        let toLabel:UILabel? = toSegment?.segmentTitle
        let toImage:UIImageView? = toSegment?.imageView
        let fromLabel:UILabel? = fromSegment?.segmentTitle
        let fromImage:UIImageView? = fromSegment?.imageView
        
        
        let transitionViews:[UIView] = [toLabel, toImage, fromLabel, fromImage].compactMap { $0
        }
        
        //Cambia colores de vistas (no se pueden animar, necesitan transicion)
        for view in transitionViews{
            UIView.transition(with: view,
                              duration: animationDuration - 0.04, //unos frames menos
                              options: .transitionCrossDissolve) {
                let newColor:UIColor? = (view == toLabel || view == toImage) ? self.segmentBackground:self.segmentTint
                if let label = view as? UILabel{
                    label.textColor = newColor
                }
                else if let imageView = view as? UIImageView{
                    imageView.tintColor = newColor
                }
            }

        }
    }
}
