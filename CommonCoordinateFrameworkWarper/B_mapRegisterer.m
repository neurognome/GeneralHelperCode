function  registered_map = B_mapRegisterer(unregistered_map,transformation_parameters)

%-------------------------------------------------------------------------%
% Step 2/2: Uses the parameters from A_transformationCreator.m to warp your
% chosen map onto the CCF.
%
% Just choose your map and transformation parameters and it'll ware your 
% map onto the CCF
%
% Written 22Jul2019 KS
%
% Updated
%-------------------------------------------------------------------------%

%% Add the path where the function resides...
addpath(genpath(fileparts(mfilename('fullpath')))); % filepath w/o output args only gives you the path

%% Load the data
if nargin == 0
    disp('Choose your matfile containing the map of interest...')
    [fn,pn] = uigetfile('.mat');
    load([pn fn]);
    
       disp('Load your transformation parameters...')
    [fn,pn] = uigetfile('.mat');
    load([pn fn]);
    
    map_cell = inputdlg('Type the variable name of the map to be warped: ');
end

new_filename = sprintf('%s_registered',map_cell{1});

unregistered_map = evalin('caller',map_cell{1});

% Load other requisite data for the warping, such as the ABI aligned map, etc
ABI_outlines = imresize(rgb2gray(imread('ABI_Aligned_Outlines.png')),[size(unregistered_map,1), size(unregistered_map,2)]);

% Process ABI_outlines to make it a logical with the outlines...
ABI_outlines(ABI_outlines == mode(ABI_outlines(:))) = 0;
ABI_outlines = logical(ABI_outlines);


registered_map = zeros(size(unregistered_map));
% do the warp
for m = 1:size(unregistered_map,3)
registered_map(:,:,m) = imwarp(unregistered_map(:,:,m),transformation_parameters.TForm,'OutputView',transformation_parameters.Rfixed);
end

assignin('caller',new_filename,registered_map);

save(sprintf('%s.mat',new_filename),new_filename);