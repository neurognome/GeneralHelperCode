function batchProcessing_2P(autorunFlag)
    if nargin < 1 || isempty(autorunFlag)
        autorunFlag = true;
    end

batchType = questdlg('What are you running','Batch Type','A_ProcessTimeSeries','C_ExtractDFF','A_ProcessTimeSeries');

addpath(fileparts(mfilename('fullpath')));  % First ouput argument returns the parent directory
twop = TwoPhotonBatchProcessor(autorunFlag);

tic;
switch batchType
    case 'A_ProcessTimeSeries'
        twop.run_AProcessTimeSeries(0); % movie flag
    case 'C_ExtractDFF'
        twop.run_CExtractDFF();
end

fprintf('Time elapsed: %0.2f sec\n', toc)