addpath(genpath('C:\Users\sit\Dropbox\PostProcessing'))
tic;
num_recordings = inputdlg('How many recordings you got?','Recording #');
num_recordings = str2num(num_recordings{1});


autorun_flag = 0;
if autorun_flag
    [tif_files] = dir('**/*nat*.tif');
    
    for ii = 1:length(tif_files)
        curr_tif_name = tif_files(ii).name;
        isFirstTif(ii) = ~isempty(strfind(curr_tif_name,'00001.tif'));
    end
    
    
    tifs_to_process = tif_files(isFirstTif);
    
    
    for ii = 1:length(tifs_to_process);
        fn{ii} = tifs_to_process(ii).name;
        pn{ii} = [tifs_to_process(ii).folder '\'];
    end
    num_recordings = length(tifs_to_process);
    
    
  %chex
    
     disp(['You have ' num2str(num_recordings) ' recordings... press any key to contiue'])
    pause
    %
    
    
    for i = 1:num_recordings
        cd(pn{i})
        try
            nf{i} = widefield_tifConvert(pn{i},fn{i});
        catch
            nf{i} = fn{i};
        end
        
    end
    
    for i = 1:num_recordings
        disp([num2str(i) '/' num2str(num_recordings)])
        cd(pn{i})
        widefieldDFF(pn{i},nf{i},1);
        clear ans
    end
    
else
    for i = 1:num_recordings
        [fn{i},pn{i}] = uigetfile('.tif');
    end
    
    %tif converting
    for i = 1:num_recordings
        cd(pn{i})
        try
            nf{i} = widefield_tifConvert(pn{i},fn{i});
        catch
            nf{i} = fn{i};
        end
        
    end
    
    % %widefieldDFF
    for i = 1:num_recordings
        disp([num2str(i) '/' num2str(num_recordings)])
        cd(pn{i})
        widefieldDFF(pn{i},nf{i},1);
        clear ans
    end
    
    toc
tic
end
