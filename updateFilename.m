function updateFilename()
disp('Choose .mat data file to correct: ')
[data_fn, data_pn] = uigetfile('*.mat');
cd(data_pn)
load(data_fn)
old_fn = data.filename;

% fix the slashes

old_fn(strfind(old_fn, filesep)) = '/'; % because windows is nasty
slash_idx = strfind(old_fn, '/');
new_fn = strcat(pwd, old_fn(slash_idx(end):end));
new_fn(strfind(new_fn, filesep)) = '/';

data.filename = new_fn;
save(data_fn, 'data');
disp('Finished.')
end