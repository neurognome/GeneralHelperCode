function batchProcessing_2P_OLD
%what you run
batch_type = questdlg('What are you running','Batch Type','A_ProcessTimeSeries','C_ExtractDFF','A_ProcessTimeSeries');
autorun_flag = 1

if autorun_flag %& strcmp(batch_type,'A_ProcessTime_Series')
    % autorun:
    switch batch_type
        case 'A_ProcessTimeSeries'
            [tif_files] = dir('**/*.tif');
            
            for ii = 1:length(tif_files)
                curr_tif_name = tif_files(ii).name;
                isFirstTif(ii) = ~isempty(strfind(curr_tif_name,'000001.ome.tif'));
            end
            
            
            tifs_to_process = tif_files(isFirstTif);
            
            
            for ii = 1:length(tifs_to_process);
                fn{ii} = tifs_to_process(ii).name;
                pn{ii} = [tifs_to_process(ii).folder '\'];
            end
            num_recordings = length(tifs_to_process);
        case 'C_ExtractDFF'
            [all_mat_files] = dir('**/*registered_data.mat');
            for ii = 1:length(all_mat_files)
                temp_mat = matfile([all_mat_files(ii).folder '\' all_mat_files(ii).name]);
                isAlreadyProcessed(ii) = isfield(temp_mat.data,'DFF') & isfield(temp_mat.data,'cellMasks');
            end
            
           all_mat_files = all_mat_files(~isAlreadyProcessed);
            for ii = 1:length(all_mat_files);
                fn{ii} = all_mat_files(ii).name;
                pn{ii} = [all_mat_files(ii).folder '\'];
            end
            num_recordings = length(all_mat_files)
    end
    
    disp(['You have ' num2str(num_recordings) ' recordings... press any key to contiue'])
    pause
else
    num_recordings = inputdlg('How many recordings you got?','Recording #');
    num_recordings = str2num(num_recordings{1});
    
    for i = 1:num_recordings
        disp([num2str(i) '/' num2str(num_recordings)])
        switch batch_type
            case 'A_ProcessTimeSeries'
                [fn{i},pn{i}] = uigetfile('.tif');
            case 'C_ExtractDFF'
                [fn{i},pn{i}] = uigetfile('.mat');
        end
    end
end
% Tif Convert, if it fails, it'll skip
tic;
for i = 1:num_recordings
    cd(pn{i})
    try
        nf{i} = subroutine_tifConvert([fn{i}]);
    catch
        nf{i} = fn{i};
    end
    
end
% 
% Run it
for i = 1:num_recordings
    disp([num2str(i) '/' num2str(num_recordings)])
    cd(pn{i})
    
    switch batch_type
        case 'A_ProcessTimeSeries'
            A_ProcessTimeSeries(nf{i},'Yes','No','No');
        case 'C_ExtractDFF'
            try
                %  C_ExtractDFF_Combined(fn{i},'None','No');
                C_ExtractDFF(fn{i},'Local Neuropil','Yes');
            end
    end
end


toc

% 


