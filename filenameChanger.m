function filenameChanger(data)
% This function changes the filename embedded in mat files in case you move them, to allow you to reprocess data more easily

% Make sure you're in the directory containing your matfile that you want to mess with

if nargin == 0
    load(uigetfile());
end

slashIdx = find(data.filename == '\',1,'last'); % Find the last slash

if isempty(slashIdx)
    slashIdx =0;
end


image_filename = data.filename(slashIdx+1:end);

data.filename = [pwd '\' data.filename(slashIdx+1:end)]; % taking the filename and appending it to the working directory

save(sprintf('%s_data.mat',image_filename(1:end-4)),'data');



