# ARKitVision

[<img src="https://img.youtube.com/vi/f5Rdk0a5lB4/hqdefault.jpg" width="600" height="300"
/>](https://www.youtube.com/embed/f5Rdk0a5lB4)


This project was awarded Best Developer Tool / Best Open Source at Vision Dev Camp 2024 [https://visiondevcamp.org]

Includes three template projects to use as starters and customize:

**ARVisualizer**
* Project which uses [https://github.com/johnhaney/ARUnderstanding] and shows all the visualizations available, including:
  * Purple Dots at each hand joint
  * Magenta Dot tracked to the device position, but placed in front of the device by 0.2 metters (so you will perceive this ad directly in front of your face)
  * Translucent orange mesh over the mesh of scene understanding elements
  * Translucent blue mesh over vertical and horizontal planes detected
  * Cyan dots over any other World Tracked anchors
  * Green plane over any Image anchors

**Common Space**
* Template project which will go into an immersive space looking for an image anchor
* The scene will have a homeEntity added, and if the image anchor is found, the homeEntity will be anchored to it's location
* Then you can add content relative to the homeEntity or just use it for converting transforms relative to the homeEntity
* This will create a common coordinate system you could use to share between devices visiting the same location

**ImmersiveAware**
* GeometryReader3D and NamedCoordinateSpace used to read the position relative to the Immersive Scene
* PositionManager receives this update and manages the state of the window as being either near, far, or none.
* When the window position moves to either near or far, PositionManager updates state and queues up Speech to speak the near or far state
* This simple example is one you can build on to make apps aware of your app's Windows and Volumes and their position in Immersive Scene
  * This also means they know position relative to each other

**SimpleARKitVision**
* Provides a code wrapper around setting up an immersive space to be able to take advantage of the various detectors and providers available in ARKit in visionOS
* This includes:
  * Hand Tracking
  * Plane Detection
  * Scene Reconstruction
  * World tracking
  * Image tracking

See Apple's documentation ARKit in visionOS [https://developer.apple.com/documentation/arkit/arkit_in_visionos] for a great intro to these features.
