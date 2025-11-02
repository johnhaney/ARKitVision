//
//  ARUAccessoryTrackingProvider.swift
//  GameControllerCheck
//
//  Created by John Haney on 11/2/25.
//

import Foundation

import ARKit
import GameController

public final class ARUnderstandingAccessoryTrackingProvider {
    private static let arSession: ARKitSession = ARKitSession()

    let accessoryCategories: Set<AccessoryCategory>
    var notificationSubscriptions: [any NSObjectProtocol] = []
    @MainActor static var anchorContinuations: [UUID: AsyncStream<AnchorUpdate<AccessoryAnchor>>.Continuation] = [:]

    @MainActor static func yield(_ update: AnchorUpdate<AccessoryAnchor>) {
        let continutations = Array(anchorContinuations.values)
        for continuation in continutations {
            continuation.yield(update)
        }
    }

    @MainActor static var anchorSession: UUID = UUID()

    private static func anchorUpdates(uuid: UUID) -> AsyncStream<AnchorUpdate<AccessoryAnchor>> {
        AsyncStream { continuation in
            let task = Task {
                let thisAnchorSession = UUID()
                await MainActor.run {
                    Self.anchorContinuations[uuid] = continuation
                    Self.anchorSession = thisAnchorSession
                }
                let devices = AccessoryTrackingProvider.connectedDevices
                let accessories: [Accessory] = await AccessoryTrackingProvider.accessories(for: devices)
                let provider = AccessoryTrackingProvider(accessories: accessories)
                try? await arSession.run([provider])
                for await update in provider.anchorUpdates {
                    guard !Task.isCancelled,
                          await Self.anchorSession == thisAnchorSession
                    else { break }
                    await Self.yield(update)
                }
            }
            continuation.onTermination = { termination in
                switch termination {
                case .cancelled: task.cancel()
                default: break
                }
            }
        }
    }

    public var updates: AsyncStream<AnchorUpdate<AccessoryAnchor>> {
        Self.updates
    }
    
    private static var updates: AsyncStream<AnchorUpdate<AccessoryAnchor>> {
        AsyncStream { continuation in
            let task = Task {
                let uuid = UUID()
                for await update in Self.anchorUpdates(uuid: uuid) {
                    guard !Task.isCancelled else { break }
                    continuation.yield(update)
                }
                continuation.finish()
                Task { @MainActor in
                    Self.anchorContinuations.removeValue(forKey: uuid)
                }
            }
            continuation.onTermination = { @Sendable termination in
                switch termination {
                case .cancelled: task.cancel()
                default: break
                }
            }
        }
    }
    
    init(accessoryCategories: Set<AccessoryCategory>) {
        self.accessoryCategories = accessoryCategories
        if !accessoryCategories.isEmpty {
            registerForControllerNotifications()
        }
    }
    
    func registerForControllerNotifications() {
        let connectedChange: @Sendable (Notification) -> Void = { notification in
            if let controller = notification.object as? GCController {
                switch controller.productCategory {
                case GCProductCategorySpatialController:
                    Task { @MainActor in
                        await Self.updateTask()
                    }
                case GCProductCategorySpatialStylus:
                    Task { @MainActor in
                        await Self.updateTask()
                    }
                default:
                    break
                }
            } else if let stylus = notification.object as? GCStylus {
                switch stylus.productCategory {
                case GCProductCategorySpatialStylus:
                    Task { @MainActor in
                        await Self.updateTask()
                    }
                default:
                    break
                }
            }
        }
        notificationSubscriptions = [
            NotificationCenter.default.addObserver(forName: .GCControllerDidConnect, object: nil, queue: nil, using: connectedChange),
            NotificationCenter.default.addObserver(forName: .GCControllerDidDisconnect, object: nil, queue: nil, using: connectedChange),
            NotificationCenter.default.addObserver(forName: .GCStylusDidConnect, object: nil, queue: nil, using: connectedChange),
            NotificationCenter.default.addObserver(forName: .GCStylusDidDisconnect, object: nil, queue: nil, using: connectedChange),
        ]
        
        // run in once now in case we have controllers already connected
        Task { @MainActor in
            await Self.updateTask()
        }
    }
    
    @MainActor static func updateTask() async {
        if !Self.anchorContinuations.isEmpty {
            Task.detached {
                for await message in updates {
                }
            }
        }
    }
}

extension AccessoryTrackingProvider {
    static var connectedDevices: [GCDevice] {
        GCController.controllers()
            .filter({
                $0.productCategory == GCProductCategorySpatialController ||
                $0.productCategory == GCProductCategorySpatialStylus })
        +
        GCStylus.styli
            .filter({
                $0.productCategory == GCProductCategorySpatialController ||
                $0.productCategory == GCProductCategorySpatialStylus })

    }
    
    static func accessories(for devices: [GCDevice]) async -> [Accessory] {
        var accessories: [Accessory] = []
        for device in devices {
            do {
                let accessory = try await Accessory(device: device)
                accessories.append(accessory)
            } catch {
            }
        }
        return accessories
    }
}

public enum AccessoryCategory: Sendable {
    case spatialControllers
    case spatialStylus
}

