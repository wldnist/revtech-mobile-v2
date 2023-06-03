import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyBYBZZenOW9HLm1THl8_Sz1SepUZ-fXkiw")
       GeneratedPluginRegistrant.register(with: self)
       if #available(iOS 10.0, *) {
             UNUserNotificationCenter.current().delegate = self
             let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
             UNUserNotificationCenter.current().requestAuthorization(
             options: authOptions,
             completionHandler: {_, _ in })
           } else {
             let settings: UIUserNotificationSettings =
             UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
             application.registerUserNotificationSettings(settings)
           }
       application.registerForRemoteNotifications()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}