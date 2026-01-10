import Flutter
import UIKit
import Firebase
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Register plugins
    GeneratedPluginRegistrant.register(with: self)
    
    // Configure Firebase
    FirebaseApp.configure()
    
    // Request notification authorization
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { granted, error in
          if granted {
            print("✅ Notification permission granted")
          } else if let error = error {
            print("❌ Notification permission error: \(error.localizedDescription)")
          } else {
            print("⚠️ Notification permission denied")
          }
        }
      )
    }
    
    // Register for remote notifications
    application.registerForRemoteNotifications()
    
    // Configure flutter_local_notifications
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
      GeneratedPluginRegistrant.register(with: registry)
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Handle remote notification registration
  override func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    print("📱 APNs token retrieved successfully")
    
    // Convert device token to string
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
    let token = tokenParts.joined()
    print("📱 APNs Token: \(token)")
    
    // Pass to Firebase
    Messaging.messaging().apnsToken = deviceToken
  }
  
  // Handle remote notification registration failure
  override func application(_ application: UIApplication,
                            didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("❌ Failed to register for remote notifications: \(error.localizedDescription)")
  }
  
  // Handle notification when app is in foreground
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo
    print("📩 Notification received in foreground: \(userInfo)")
    
    // Show notification even when app is in foreground
    if #available(iOS 14.0, *) {
      completionHandler([[.banner, .badge, .sound]])
    } else {
      completionHandler([[.alert, .badge, .sound]])
    }
  }
  
  // Handle notification tap
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    print("👆 Notification tapped: \(userInfo)")
    
    completionHandler()
  }
}
