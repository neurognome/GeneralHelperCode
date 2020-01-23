% Things ot owrk on
% I wouldn't particularly trust the x and y position, because they're arbitrarily in reference to the edges of the frame...
% the mouse eye is probably better referenc. We'll take the football shape, then get the centroid and axes, the plot the x
% and y movement as deviation from these reference points


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


eye.calibrate()
eye.calculateCoG();

% Plot over time to check performance of detection
eye.checkPerformance()

