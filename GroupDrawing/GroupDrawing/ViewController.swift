//
//  ViewController.swift
//  GroupDrawing
//
//  Created by Rodrigo Vivas on 02/10/21.
//

import UIKit
import PencilKit

class ViewController: UIViewController {
    
    private var addedNewStroke = false
    
    private var removedStrokes = [PKStroke]() {
        didSet {
            undoBarButtonItem.isEnabled = !canvasView.drawing.strokes.isEmpty
            redoBarButtonItem.isEnabled = !removedStrokes.isEmpty
        }
    }
    
    private lazy var canvasView: PKCanvasView = {
        let canvasView = PKCanvasView()
        canvasView.drawingPolicy = .anyInput
        canvasView.delegate = self
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        return canvasView
    }()
    
    private lazy var toolPicker: PKToolPicker = {
        let toolPicker = PKToolPicker()
        return toolPicker
    }()
    
    private lazy var undoBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "arrow.uturn.backward"), style: .plain, target: self, action: #selector(handleUndoStroke))
        button.isEnabled = false
        return button
    }()
    
    private lazy var redoBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "arrow.uturn.forward"), style: .plain, target: self, action: #selector(handleRedoStroke))
        button.isEnabled = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupCanvasView()
        setupToolPicker()
        
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Canvas"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(handleClearCanvas))
        navigationItem.rightBarButtonItems = [redoBarButtonItem, undoBarButtonItem]
    }
    
    @objc private func handleClearCanvas() {
        canvasView.drawing = PKDrawing()
        removedStrokes.removeAll()
    }
    
    @objc private func handleUndoStroke() {
        if !canvasView.drawing.strokes.isEmpty {
            let stroke = canvasView.drawing.strokes.removeLast()
            removedStrokes.append(stroke)
        }
    }
    
    @objc private func handleRedoStroke() {
        if !removedStrokes.isEmpty {
            let stroke = removedStrokes.removeLast()
            canvasView.drawing.strokes.append(stroke)
        }
    }
    
    private func setupToolPicker() {
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
    }
    
    private func setupCanvasView() {
        view.addSubview(canvasView)
        NSLayoutConstraint.activate([
            canvasView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            canvasView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            canvasView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            canvasView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }


}

// MARK: CanvasViewDelegate
extension ViewController: PKCanvasViewDelegate {
    func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
        addedNewStroke = true
    }
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        if addedNewStroke {
            addedNewStroke = false
            removedStrokes.removeAll()
        }
    }
}
