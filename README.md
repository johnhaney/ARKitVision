# ARKitVision

This project was awarded Best Developer Tool / Best Open Source at Vision Dev Camp 2024 [https://visiondevcamp.org]

Includes two template projects to use as starters and customize:

**Common Space**
* Template project which will go into an immersive space looking for an image anchor
* The scene will have a homeEntity added, and if the image anchor is found, the homeEntity will be anchored to it's location
* Then you can add content relative to the homeEntity or just use it for converting transforms relative to the homeEntity
* This will create a common coordinate system you could use to share between devices visiting the same location

**SimpleARKitVision**
* Provides a code wrapper around setting up an immersive space to be able to take advantage of the various detectors and providers available in ARKit in visionOS
* This includes:
*   Hand Tracking
*   Plane Detection
*   Scene Reconstruction
*   World tracking
*   Image tracking

See Apple's documentation ARKit in visionOS [https://developer.apple.com/documentation/arkit/arkit_in_visionos] for a great intro to these features.
