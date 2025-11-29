import Flutter
import UIKit

public class RestartPlugin: NSObject, FlutterPlugin {
    // CHANGE 1: Update callback to accept a FlutterPluginRegistry
    @objc public static var generatedPluginRegistrantRegisterCallback: (FlutterPluginRegistry) -> Void = { _ in
        NSLog("WARNING: generatedPluginRegistrantRegisterCallback is not assigned by the AppDelegate.")
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
            
            // 1. Create the new engine
            let engine = FlutterEngine(name: "io.flutter.flutter.app")
            engine.run(
                withEntrypoint: nil,
                libraryURI: nil,
                initialRoute: nil,
                entrypointArgs: args
            )
            
            // 2. CHANGE 2: Pass the NEW engine to the callback
            // This ensures plugins are registered on THIS engine, not the old one.
            RestartPlugin.generatedPluginRegistrantRegisterCallback(engine)
            
            // 3. Set the UI
            UIApplication.shared.keyWindow?.rootViewController = FlutterViewController(
                engine: engine,
                nibName: nil,
                bundle: nil
            )
            
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}