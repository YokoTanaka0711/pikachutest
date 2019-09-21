//
//  ViewController.swift
//  Pikachu
//
//  Created by Jun Takahashi on 2019/05/15.
//  Copyright © 2019 Jun Takahashi. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import AVFoundation

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var audioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        //特徴点を表示
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        //特徴点を表示
        sceneView.autoenablesDefaultLighting = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:
            #selector(tapped))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        configureAudioPlayer()
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        //水平面を検出
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    func createPikaNode() -> SCNNode {
        let pikaScene = SCNScene(named: "art.scnassets/Pikachu/PikachuF_ColladaMax.scn")!
        
        let pikaNode = SCNNode()
        
        for childNode in pikaScene.rootNode.childNodes {
            pikaNode.addChildNode(childNode)
        }
        
        let (min, max) = (pikaNode.boundingBox)
        let h = max.y - min.y
        let magnification = 0.4 / h
        pikaNode.scale = SCNVector3(magnification, magnification, magnification)
        pikaNode.name = "pika"
        
        return pikaNode
    }
    
    @objc func tapped(sender: UITapGestureRecognizer) {
        // タップされた位置を取得
        let tapLocation = sender.location(in: sceneView)
        
        // 第二引数　existingPlaneUsingExtent -> 検出された平面内
        let hitTest = sceneView.hitTest(tapLocation,
                                        types: .existingPlaneUsingExtent)
        
        if !hitTest.isEmpty {
            // タップした箇所が取得できていればアンカーをシーンに追加
            let anchor = ARAnchor(transform: hitTest.first!.worldTransform) //ワールド座標系に対するヒットテスト結果の位置と方向
            sceneView.session.add(anchor: anchor)
        }
    }
    
    func configureAudioPlayer(){
        guard let soundData = NSDataAsset(name: "Pikaaaa")?.data else { return }
        do {
            self.audioPlayer = try AVAudioPlayer(data: soundData, fileTypeHint: "mp3")
            self.audioPlayer.prepareToPlay()
        } catch {
            print("💬 Error")
        }
    }
    
    //ノードが追加されたときに呼ばれる
    //新しいアンカーに対応するノードがシーンに追加されたことをデリゲートに伝えてくれている
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        //平面を検知したときにも呼ばれる
        guard !(anchor is ARPlaneAnchor) else { return } //自動で検出した平面では何もしない
        let pikaNode = createPikaNode()
        node.addChildNode(pikaNode)
        self.audioPlayer.play()
        self.audioPlayer.currentTime = 0

    }
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
