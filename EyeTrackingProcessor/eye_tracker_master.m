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
eye.cropMovie('Rectangle');     % 'Rectangle' or 'Points' 

% Detect the pupil
eye.detectPupil();


eye.calibrate()
eye.calculateCoG();

% Plot over time to check performance of detection
eye.checkPerformance(14300:15000)

frames = 1:size(eye.cropped_movie, 3);
ct = 1;
for frame = frames
    pupil_position(ct, :) = eye.pupil(frame).Centroid;
    ct = ct  + 1;
end