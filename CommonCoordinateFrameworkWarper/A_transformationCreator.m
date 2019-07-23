function [TForm,Rfixed] = A_transformationCreator(VFS_raw)

%-------------------------------------------------------------------------%
% Step 1/2: Creates the transformation parameters
% After this, run the B_mapRegisterer.m to actually register your map to the CCF
%
%
% Used to warp sign maps from different mice onto the ABI common
% coordinate framework for aggregate analyses.
%
% Written 22Jul2019 KS
%
% Updated
%-------------------------------------------------------------------------%

%% Add the path where the function resides...
addpath(genpath(fileparts(mfilename('fullpath')))); % filepath w/o output args only gives you the path

%% Load the data
if nargin == 0
    disp('Choose your matfile containing the sign map to be warped...')
    [fn,pn] = uigetfile('.mat');
    load([pn fn])
end

% Load other requisite data for the warping, such as the ABI aligned map, etc
ABI_map      = imresize(imread('ABI_Aligned_SignMap.png'),[size(VFS_raw,1), size(VFS_raw,2)]);
Rfixed = imref2d(size(ABI_map)); % define a "world axis" for the images to reference onto

ImageRegistrationApp(VFS_raw,ABI_map);
uiwait

try
    TForm = evalin('base','TForm'); % Not a great way of doing it... but it fetches the TForm from the base workspace, which the app has to output to...
catch
    a=0;
    while a == 0
        [movingPoints, fixedPoints] = cpselect(VFS_raw,ABI_map,'Wait',true); % choose at least 3 noncollinear points
        
        TForm = fitgeotrans(movingPoints,fixedPoints,'affine'); %use the control points to define a transformation matrix
        
        registered_VFS_raw = imwarp(VFS_raw,TForm,'OutputView',Rfixed); % warp the moving F0 to check performance
        
        % compare unregistered vs registered to check performance, if looks
        % good, then continue
        figure('units','normalized','outerposition',[0 0 1 1]);
        subplot(1,2,1)
        imshowpair(VFS_raw,ABI_map);
        title('Non-registered')
        subplot(1,2,2)
        imshowpair(registered_VFS_raw,ABI_map);
        title('Registered')
        
        % prompt for good registration manual check
        good_registration = questdlg('Does the registration look good?','Registration Performance','Yes','No','Yes');
        
        close all;
        
        switch good_registration
            case 'Yes'
                a = 1; % break the loop and continue
            case 'No'
                disp('Probably an issue with your control points... let''s choose them again...');
        end
    end
end

transformation_parameters.TForm = TForm;
transformation_parameters.Rfixed = Rfixed;

save('transformation_parameters.mat','transformation_parameters');

evalin('base','clear Registered TForm');

