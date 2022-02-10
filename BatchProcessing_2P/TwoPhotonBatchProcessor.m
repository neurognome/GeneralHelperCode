classdef TwoPhotonBatchProcessor < handle
	properties
		autorunFlag logical

		filenames cell
		pathnames cell

		nRecordings double
	end

	methods
		function obj = TwoPhotonBatchProcessor(autorunFlag)
			addpath(genpath('C:\Users\sit\Dropbox\PostProcessing\Goard_Method'))
			obj.autorunFlag = autorunFlag;
		end

		function run_tifConvert(obj)
			if obj.autorunFlag
				obj.autogetTifFilenames(true)
				obj.pauseAndCheck()
			else
				obj.promptgetFilenames('.tif')
			end

			obj.filenameChecker();
			for r = 1:obj.nRecordings
				cd(obj.pathnames{r})
				subroutine_tifConvert_old(obj.filenames{r});
				obj.checkAndReport(r)
			end
		end

		function run_AProcessTimeSeries(obj, movie_flag)
			if obj.autorunFlag
				obj.autogetTifFilenames(false);
				% obj.checkForMatfiles();
				obj.pauseAndCheck();
			else
				obj.promptgetFilenames('.tif')
			end

			obj.filenameChecker();
			for r = 1:obj.nRecordings
				cd(obj.pathnames{r})
				if movie_flag
					warning('Creating movie, don''t forget to change this later')
					A_ProcessTimeSeries(obj.filenames{r}, 'Yes', 'No', 'Yes');
				else
					A_ProcessTimeSeries(obj.filenames{r}, 'Yes', 'No', 'No');
				end                
				obj.checkAndReport(r)
			end
		end

		function run_CExtractDFF(obj)
			if obj.autorunFlag
				obj.autogetMatFilenames()
				obj.pauseAndCheck()
			else
				obj.promptgetFilenames('.mat');
			end

			%   obj.filenameChecker();
			for r = 1:obj.nRecordings
				cd(obj.pathnames{r})
				C_ExtractDFF(obj.filenames{r}, 'Local Neuropil', 'Yes')
				obj.checkAndReport(r)
			end
		end
	end

	methods (Access = private)

		function [] = filenameChecker(obj)
			%             for f = 1:length(obj.filenames)
			%                 if length(obj.filenames{f}) > 50
			%                     keyboard
			%                     error('Something bad happened with the filenames, get this fixed now')
			%                 end
			%             end
		end

		function obj = checkForMatfiles(obj)
			is_processed = false(1, length(obj.pathnames));
			ct = 1;
			for p = obj.pathnames
				cd(p{:})
				matfiles_dir = dir('*.mat');
				if ~isempty(matfiles_dir)
					is_processed(ct) = true;
				end
				ct =ct + 1;
			end
			obj.pathnames = obj.pathnames(~is_processed);
			obj.filenames = obj.filenames(~is_processed);
			obj.nRecordings = length(obj.filenames); % update
		end

		function obj = autogetTifFilenames(obj, first_tif_only)
			tifFiles = dir('**/*.tif');
			isFirstTif = false(1, length(tifFiles));
			isSingleImage = false(1, length(tifFiles));

			% First check
			for f = 1:length(tifFiles)
				isFirstTif(f) = contains(tifFiles(f).name, '000001.ome.tif');
				isSingleImage(f) = contains(tifFiles(f).name, 'SingleImage');
                hasRegistered(f) = contains(tifFiles(f).name, '_registered.tif');
				isOther(f) = contains(tifFiles(f).folder, 'References') || contains(tifFiles(f).folder, 'MIP');
			end
            
            isRegistered = false(1, numel(tifFiles));
            for r = find(hasRegistered)
                registered_folder = tifFiles(r).folder;
                for ii = 1:numel(tifFiles)
                    if strcmp(tifFiles(ii).folder, registered_folder)
                        isRegistered(ii) = true;
                    end
                end
            end
            
            
			if first_tif_only
				tifsToProcess = tifFiles(isFirstTif & ~isSingleImage);
			else
				tifsToProcess = tifFiles(~isSingleImage & ~isOther & ~isRegistered);
            end
            
			for t = 1:length(tifsToProcess)
				obj.filenames{t} = tifsToProcess(t).name;
				obj.pathnames{t} = [tifsToProcess(t).folder '\'];
			end
			obj.nRecordings = length(tifsToProcess);
		end

		function obj = promptgetFilenames(obj, fileType)
			nRecordings_cell = inputdlg('How many recordings you got?','Recording #');
			obj.nRecordings = str2double(nRecordings_cell{1});

			for r = 1:obj.nRecordings
				disp(['Choose file ' num2str(r) '/' num2str(obj.nRecordings)])
				[obj.filenames{r}, obj.pathnames{r}] = uigetfile(fileType);
			end
		end

		function obj = autogetMatFilenames(obj)
			allMatFiles = dir('**/*registered_data.mat');
			isAlreadyProcessed = false(1, length(allMatFiles));
			for m = 1:length(allMatFiles)
				temp_mat = importdata([allMatFiles(m).folder '\' allMatFiles(m).name]);
				isAlreadyProcessed(m) = isfield(temp_mat,'DFF') & isfield(temp_mat,'cellMasks');
			end

			allMatFiles = allMatFiles(~isAlreadyProcessed);
			for m = 1:length(allMatFiles)
				obj.filenames{m} = allMatFiles(m).name;
				obj.pathnames{m} = [allMatFiles(m).folder '\'];
			end
			obj.nRecordings = length(allMatFiles);
		end


		function [] = pauseAndCheck(obj)
			fprintf('You have %d recordings, press any key to continue...\n', obj.nRecordings)
			pause
		end

		function [] = checkAndReport(obj, iteration)
			fprintf('Processing recording %d / %d\n', iteration, obj.nRecordings)
		end
    end
    
end
