import Flutter
import UIKit

public class RestartPlugin: NSObject, FlutterPlugin {
    
    // 🔑 FIX: Changed the callback name and signature. It now accepts the 
    // FlutterPluginRegistry (which FlutterEngine implements), allowing 
    // the AppDelegate to correctly register plugins with the new engine.
    @objc public static var pluginRegisterFunction: (FlutterPluginRegistry) -> Void = { registry in
        NSLog("WARNING: pluginRegisterFunction is not assigned by the AppDelegate. Restarting will likely fail to load plugins.")
    }
    
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
            
            // Create a brand new engine instance.
            let engine = FlutterEngine(name: "io.flutter.flutter.app.newEngine")
            
            // Run the new engine.
            engine.run(
                withEntrypoint: nil,
                libraryURI: nil,
                initialRoute: nil,
                entrypointArgs: args
            )
            
            // Set the new engine's view controller as the root.
            let flutterViewController = FlutterViewController(
                engine: engine,
                nibName: nil,
                bundle: nil
            )
            UIApplication.shared.keyWindow?.rootViewController = flutterViewController

            // 🔑 CRITICAL FIX: Call the registration function (assigned in AppDelegate)
            // passing the NEW engine as the registry. This must be done asynchronously
            // to give the engine time to fully initialize.
            DispatchQueue.main.async {
                RestartPlugin.pluginRegisterFunction(engine)
            }
            
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}