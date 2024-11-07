# VideoTimeline
This project demonstrates the implementation of a custom TimelineView for a video editing interface inspired by the CapCut application. The TimelineView supports essential editing interactions like zooming, trimming, and track manipulation, its just UI implementation just to simulate the timeline video editor. The app is built using UIKit, with an emphasis on clean architecture through the MVVM pattern.

## Features
- Multiple Tracks: The TimelineView includes multiple tracks that represent different video or audio segments. Each track is displayed as a horizontal strip, filled with color-coded blocks representing individual segments.
- Pinch-to-Zoom Functionality: Users can zoom in and out on the timeline to get a detailed or overview view of the segments. The zooming effect is smooth and confined within the bounds of each track, preventing overlap with adjacent screens.
- Track Movement and Swapping: Tracks can be reordered or swapped to simulate the process of rearranging video or audio layers in a timeline. The UI provides intuitive interactions for moving and repositioning tracks.
- Trimming Handles: Each segment within a track has trimming handles at the ends, allowing users to adjust the segment length. The trimming functionality includes minimum length checks and prevents segments from overlapping with adjacent segments.

## Implementation Details
- Programmatic UI: All UI components are created programmatically, without the use of storyboards, to offer greater flexibility and control over layout and constraints.
- No External Frameworks: The implementation relies solely on UIKit and core Swift libraries, as per the task requirements, without using AVFoundation or other multimedia frameworks.
- Zoom Confined to Track Bounds: The pinch-to-zoom feature is restricted to the visible area of each track to ensure clean transitions between screens and prevent overlap.
- Documentation: Inline documentation is included where required, providing an explanation of key functions, and properties for easy reference.

## Future Improvements
While the test task requirements have been met, here are some potential enhancements for a full-featured video editor:
- Adding playback functionality with AVFoundation for actual media preview.
- More complex data handling, such as loading tracks from external sources or APIs.
- Smoother animations for user interactions like track movement, swapping, and trimming.

## Instructions
- Run the App: Open the project in Xcode, build, and run the app on a simulator or physical device.
- Testing the Features:
    - Use pinch gestures to zoom in and out on the timeline.
    - Move and swap tracks to change it.
    - Trim segments by dragging the trim handles on each segment.
