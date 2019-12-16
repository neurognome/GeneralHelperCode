classdef TwoPhotonBatchProcessor < handle
    properties
        autorunFlag logical
        
        filenames cell
        pathnames cell
        
        nRecordings double
    end
    
    methods
        function obj = TwoPhotonBatchProcessor(autorunFlag)
            obj.autorunFlag = autorunFlag;
        end
        
        function run_AProcessTimeSeries(obj)
            if obj.autorunFlag
                obj.autogetTifFilenames()
                obj.pauseAndCheck()
            else
                obj.promptgetFilenames('.tif')
            end
            
            obj.filenameChecker();
            
            for r = 1:obj.nRecordings
                cd(obj.pathnames{r})
                try
                    currentFilename = subroutine_tifConvert_KS(obj.filenames{r});
                catch
                    currentFilename = obj.filenames{r};
                end
                A_ProcessTimeSeries_KS(currentFilename, 'Yes', 'No', 'No');
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
                C_ExtractDFF(obj.filenames{r}, 'LocalNeuropil', 'Yes')
                obj.checkAndReport(r)
            end
        end
    end
    
    methods (Access = private)
        
        function [] = filenameChecker(obj)
            for f = 1:length(obj.filenames)
                if length(obj.filenames{f}) > 50
                    error('Something bad happened with the filenames, get this fixed now')
                end
            end
        end
        
        function obj = autogetTifFilenames(obj)
            tifFiles = dir('**/*.tif');
            isFirstTif = false(1, length(tifFiles));
            isSingleImage = false(1, length(tifFiles));
            for f = 1:length(tifFiles)
                isFirstTif(f) = contains(tifFiles(f).name, '000001.ome.tif');
                isSingleImage(f) = contains(tifFiles(f).name, 'SingleImage');
            end
            tifsToProcess = tifFiles(isFirstTif & ~isSingleImage);
            
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
                temp_mat = matfile([allMatFiles(m).folder '\' allMatFiles(m).name]);
                isAlreadyProcessed(m) = isfield(temp_mat.data,'DFF') & isfield(temp_mat.data,'cellMasks');
            end
            
            allMatFiles = allMatFiles(~isAlreadyProcessed);
            for m = 1:length(allMatFiles)
                obj.filenames{m} = allMatFiles(m).name;
                obj.filenames{m} = [allMatFiles(m).folder '\'];
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