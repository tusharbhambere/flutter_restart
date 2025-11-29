import Flutter
import UIKit

public class RestartPlugin: NSObject, FlutterPlugin {
    
    // ✅ Renamed the callback variable to match the AppDelegate code
    public static var pluginRegisterFunction: ((FlutterPluginRegistry) -> Void)?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "in.farmako/restart", binaryMessenger: registrar.messenger())
        let instance = RestartPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String:Any]
        switch call.method {
        case "restart":
            let args = arguments?["args"] as? [String]
            
            // 1. Create the new engine
            let engine = FlutterEngine(name: "io.flutter.flutter.app")
            engine.run(
                withEntrypoint: nil,
                libraryURI: nil,
                initialRoute: nil,
                entrypointArgs: args
            )
            
            // 2. Pass the NEW engine to the AppDelegate for plugin registration
            RestartPlugin.pluginRegisterFunction?(engine)
            
            // 3. Create the new Flutter View Controller
            let newFlutterViewController = FlutterViewController(
                engine: engine,
                nibName: nil,
                bundle: nil
            )
            
            // 4. CRITICAL FIX for black screen on real devices
            if let window = UIApplication.shared.keyWindow {
                
                // Swap the root view controller
                window.rootViewController = newFlutterViewController
                
                // Ensure the new view is drawn and visible
                window.makeKeyAndVisible()
            } else {
                NSLog("RestartPlugin Error: Could not find key window during restart.")
            }
            
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}