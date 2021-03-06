//
//  TripViewController.swift
//  TripCard
//
//  Makan Fofana
//

import UIKit
import Parse
import Foundation

class TripViewController: UIViewController {
    

    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var collectionView: UICollectionView! 
    
    private var trips  = [Trip]()
    
    //Loading trip from the Parse database
    @IBAction func reloadButtonTapped(_ sender: Any) {
        loadTripsFromParse()
    }
    
    
    /*private var trips: Array = [Trip(tripId: "Paris001", city: "Paris", country: "France", featuredImage: UIImage(named: "paris"), price: 2000, totalDays: 5, isLiked: false),
                                Trip(tripId: "Rome001", city: "Rome", country: "Italy", featuredImage: UIImage(named: "rome"), price: 800, totalDays: 3, isLiked: false),
                                Trip(tripId: "Instanbul001", city: "Instanbul", country: "Turkey", featuredImage: UIImage(named: "istanbul"), price: 2200, totalDays: 10, isLiked: false),
                                Trip(tripId: "London001", city: "London", country: "United Kingdom", featuredImage: UIImage(named: "london"), price: 3000, totalDays: 4, isLiked: false),
                                Trip(tripId: "Sydney001", city: "Sydney", country: "Australia", featuredImage: UIImage(named: "sydney"), price: 2500, totalDays: 8, isLiked: false),
                                Trip(tripId: "Santorini001", city: "Santorini", country: "Greece", featuredImage: UIImage(named: "santorini"), price: 1800, totalDays: 7, isLiked: false),
                                Trip(tripId: "NewYork001", city: "New York", country: "United States", featuredImage: UIImage(named: "newyork"), price: 900, totalDays: 3, isLiked: false),
                                Trip(tripId: "Kyoto001", city: "Kyoto", country: "Japan", featuredImage: UIImage(named: "kyoto"), price: 1000, totalDays: 5, isLiked: false)
                                ]
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTripsFromParse()
        // Makes the collection view transparent
        collectionView.backgroundColor = UIColor.clear
        
        // Apply blurring effect
        backgroundImageView.image = UIImage(named: "cloud")
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView)
        
        //Resizes collection view for 4 inch devices
        if UIScreen.main.bounds.size.height == 56.0 {
            let flowLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            flowLayout.itemSize = CGSize(width: 250.0, height: 330.0)
        }
        
        //Swipe Gesture Recognizer For Deletion
        let swipeUpRecognizer  = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeUpRecognizer.direction = .up
        swipeUpRecognizer.delegate = self
        self.collectionView.addGestureRecognizer(swipeUpRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
}




extension TripViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trips.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! TripCollectionViewCell
        
        cell.cityLabel.text = trips[indexPath.row].city
        cell.countryLabel.text = trips[indexPath.row].country
        //cell.imageView.image = trips[indexPath.row].featuredImage
        cell.priceLabel.text = "$\(String(trips[indexPath.row].price))"
        cell.totalDaysLabel.text = "$\(String(trips[indexPath.row].totalDays))"
        cell.isLiked = trips[indexPath.row].isLiked
        
        //Applying the round corners
        cell.layer.cornerRadius = 4.0
        
        cell.delegate = self
        
        //Load image in the background from parse database
        cell.imageView.image = UIImage()
        if let featuredImage = trips[indexPath.row].featuredImage {
            featuredImage.getDataInBackground(block: { (imageData, error) in
                if let tripImageData = imageData {
                    cell.imageView.image = UIImage(data: tripImageData)
                }
            })
        }
        
        return cell
    }
    
    //Parse Learning Method
    
    func loadTripsFromParse(){
        //Clearing the array
        trips.removeAll(keepingCapacity: true)
        collectionView.reloadData()
        
        //Pulling Data From Parse
        let query = PFQuery(className: "Trip")
        query.cachePolicy = PFCachePolicy.networkElseCache
        query.findObjectsInBackground{(objects, error) -> Void in
            
            if let error = error {
                print("Error: \(error) \(error.localizedDescription)")
                return
            }
            
            if let objects = objects {
                for (index, object) in objects.enumerated() {
                    
                    //Convert PFObject into a Trip object
                    let trip = Trip(pfObject: object)
                    self.trips.append(trip)
                    
                    let indexPath = IndexPath(row: index, section: 0)
                    self.collectionView.insertItems(at: [indexPath])
                    
                }
            }
        }
    }
    
    
    
}


    extension TripViewController: TripCollectionCellDelegate {
        
        func didLikeButtonPressed(Cell: TripCollectionViewCell) {
            if let indexPath = collectionView.indexPath(for: Cell) {
                trips[indexPath.row].isLiked = trips[indexPath.row].isLiked ? false : true
                Cell.isLiked = trips[indexPath.row].isLiked
                
                //Updating the trip on Parse
                trips[indexPath.row].toPFObject().saveInBackground { (success, error) in
                    if (success) {
                        print("Succesfully updated the trip")
                    } else {
                        print("Error: \(error?.localizedDescription ?? "Unknown Error")")
                    }
                }
            }
        }
    }


extension TripViewController: UIGestureRecognizerDelegate {
    
    @objc func handleSwipe(gesture: UISwipeGestureRecognizer) {
        let point = gesture.location(in: self.collectionView)
        
        if (gesture.state == UIGestureRecognizer.State.ended) {
            if let indexPath = collectionView.indexPathForItem(at: point) {
                // Remove trip from Parse, array and collection view
                trips[indexPath.row].toPFObject().deleteInBackground(block: { (success, error) -> Void in
                    if (success) {
                        print("Successfully removed the trip")
                    } else {
                        print("Error: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    
                    self.trips.remove(at: indexPath.row)
                    self.collectionView.deleteItems(at: [indexPath])
                })
            }
        }
    }
}
    

