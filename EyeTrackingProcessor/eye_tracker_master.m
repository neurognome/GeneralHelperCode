% Instantiate the class
eye = EyeTracker();

% Read the video
eye.readEyeTrackingVideo();

% Clean dropped frames
eye.cleanVideo('interpolate'); % method can be 'interpolate' or 'drop'

% Crop to the eye
eye.cropMovie(); 

% Detect the pupil
eye.detectPupil();

% Plot over time to check performance of detection
eye.checkPerformance()
