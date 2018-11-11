//
//  ViewController.swift
//  DirectMarketingApp
//
//  Created by Megumi Mimura on 2018/11/06.
//  Copyright © 2018 三村恵. All rights reserved.
//
import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var myAnnotation: MKAnnotationView!
    
    // CLLocationManagerクラスのインスタンスlocationManagerを初期化
    var locationManager: CLLocationManager!
    
    // var userLocation: CLLocationCoordinate2D!
    // var destLocation: CLLocationCoordinate2D!
    
    // UserDefaultsの保存・読み込み時に使う名前
    let userDefName = "pins"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // locationManagerオブジェクトの初期化(setupLocationManager()メソッドの実行)
        setupLocationManager()
       
        // 現在地(ユーザの位置)に追従
        mapView.userTrackingMode = MKUserTrackingMode.follow
        
        // 保存されているピンを配置
        loadPins()
        
        mapView.delegate = self
    }
    
    // 位置情報を管理するメソッド
    func setupLocationManager() {
        locationManager = CLLocationManager()
        
        guard let locationManager = locationManager else { return }
        
        // アプリ使用中のみ位置情報を許可する
        locationManager.requestWhenInUseAuthorization()
        
        let status = CLLocationManager.authorizationStatus()
        
        // 「アプリ使用中の位置情報取得」の許可が得られた場合のみマネージャ設定をする
        if status == .authorizedWhenInUse {
            
            // 管理マネージャが更新するタイミングは10m毎
            locationManager.distanceFilter = 10
            
            // 位置情報取得を開始する
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let coordinate = locations.last?.coordinate {
            // 現在地を拡大して表示する
           let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
           let region = MKCoordinateRegion(center: coordinate, span: span)
           mapView.region = region
        }
        
        let location = locations.first
        let latitude = location?.coordinate.latitude
        let longitude = location?.coordinate.longitude
        
        print("latitude: \(latitude!)\nlongitude: \(longitude!)")
    }
    
    // ピンの立てる
    func savePin(_ pin: Pin) {
        let userDefaults = UserDefaults.standard
        
        // 保存するピンをUserDefaults用に変換します。
        let pinInfo = pin.toDictionary()
        
        if var savedPins = userDefaults.object(forKey: userDefName) as? [[String: Any]] {
            // すでにピン保存データがある場合、それに追加する形で保存します。
            savedPins.append(pinInfo)
            userDefaults.set(savedPins, forKey: userDefName)
            
        } else {
            // まだピン保存データがない場合、新しい配列として保存します。
            let newSavedPins: [[String: Any]] = [pinInfo]
            userDefaults.set(newSavedPins, forKey: userDefName)
        }
    }
    
    
    // 既に保存されているピンを取得
    func loadPins() {
        let userDefaults = UserDefaults.standard
        
        if let savedPins = userDefaults.object(forKey: userDefName) as? [[String: Any]] {
            
            // 現在のピンを削除
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            for pinInfo in savedPins {
                let newPin = Pin(dictionary: pinInfo)
                self.mapView.addAnnotation(newPin)
            }
        }
    }
    
    /*
    // ピンをカスタマイズ
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if (annotation is MKUserLocation) {
            // ユーザの現在地の青丸マークは置き換えない
            return nil
            
        } else {
            // CustomAnnotationの場合に画像を配置
            let identifier = "Pin"
            var annotationView: MKAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView == nil {
                annotationView = MKAnnotationView.init(annotation: annotation, reuseIdentifier: identifier)
            }
            annotationView?.image = UIImage.init(named: "vegetables") // 任意の画像名
            annotationView?.annotation = annotation
            annotationView?.canShowCallout = true  // タップで吹き出しを表示
            return annotationView
        }
    }
 */
 
    
    // マップ上をロングタップした際にピンを登録
    @IBAction func longTapMapView(_ sender: UILongPressGestureRecognizer) {
        // ロングタップイベントは「ロングタップと認識した時」と「ロングタップが終了したとき」の2回呼ばれます。
        // 1回だけ呼ばれればよいので、認識時の呼び出しで以外は何もしないようにしています。
        if sender.state != UIGestureRecognizer.State.began {
            // ロングタップ認識時以外では何もしない
            return
        }
        
        // 位置情報を取得します。
        let point = sender.location(in: mapView)
        let geo = mapView.convert(point, toCoordinateFrom: mapView)
        
        // アラートの作成
        
        let alert = UIAlertController(title: "産直を登録しますか？", message: "産直として登録します", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "登録", style: .default, handler: { (action) -> Void in
        
            
            
            // ピンの登録
            let pin = Pin(geo: geo, text: alert.textFields?.first?.text)
            self.mapView.addAnnotation(pin)
            
            self.savePin(pin)
        }))
        
        
        // ピンに登録するテキスト用の入力フィールドをアラートに追加します。
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "産直名"
        })
        
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "住所"
        })
 
        
        // アラートの表示
        present(alert, animated: true, completion: nil)
    }
    
}
