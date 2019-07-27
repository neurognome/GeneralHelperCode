classdef dataObject < dynamicprops
    % -------------------------------------------------------------------------%
    % Special object used to store data and pass it around. It first takes
    % whatever data you want to pass in as an input, but you can also add or
    % remove data as you'd like. All data are public, so you can access
    % individual data stored just by calling your object.dataYouWant
    %
    %
    % Usage: data = dataObject('var1','var2','var3'), always takes strings
    % Written 26Jul2019 KS
    % Updated 27Jul2019 KS Better handling of inputs and refactored 
    %                      message printer
    % -------------------------------------------------------------------------%
    
    properties (Access = private)
        dynamicproperties
    end
    
    methods
        function obj = dataObject(varargin)
            
            for ii = 1:nargin % Loops through the input arguments
                try
                    evalin('caller',varargin{ii})
                    p(ii) = obj.addprop(varargin{ii}); % adds them as dynamic properties
                    obj.(varargin{ii}) = evalin('caller',varargin{ii}); % Fills in those properties with the values
                catch
                    obj.msgPrinter(sprintf('Variable %s doesn''t exist, skipping...\n',varargin{ii}));
                end
                
            end
            
            obj.dynamicproperties = p; % here we assign the private dynamicproperties property, mainly for controlling these data
        end
        
        function addData(obj,varargin) % In order to add more data to our object
            for ii = 1:nargin-1 % because there will always be "obj" there
                try
                    p(ii) = obj.addprop(varargin{ii}); % adds them as dynamic properties
                    obj.(varargin{ii}) = evalin('caller',varargin{ii}); % Fills in those properties with the values
                    obj.dynamicproperties = [obj.dynamicproperties p]; % extending the thing
                catch
                    obj.msgPrinter(sprintf('%s is already a property, skipped...\n',varargin{ii}))
                end
            end
        end
        
        function deleteData(obj,varargin) % Getting rid of individual fields of data
            try
                dynamic_property_list = {obj.dynamicproperties.Name}; % Find the properties you want to get rid of
                isDeleteProperty = ismember(dynamic_property_list,varargin);
                delete(obj.dynamicproperties(isDeleteProperty)) % Get rid of thew
                obj.dynamicproperties = obj.dynamicproperties(~isDeleteProperty); % Update reference list
            catch
                obj.msgPrinter('Something went wrong, properties not deleted \n')
            end
        end
        
        function clearAllData(obj) % For clearing your entire data object, starting from scratch
            delete(obj.dynamicproperties);
            obj.dynamicproperties = [];
        end
        
        function exportData(obj,varargin) % To output stored variables into the workspace
            
            obj.msgPrinter('Not recommended (uses assignin), better to access the properties directly...\n')
            props = properties(obj);
            
            if nargin < 2
                for ii = 1:size(props,1)
                    assignin('caller',props{ii},obj.(props{ii})); % not sure if base or caller better, we'll see...
                end
            else
                isExportProperty = ismember(props,varargin);
                
                for ii = 1:size(props,1)
                    if isExportProperty(ii)
                        assignin('caller',props{ii},obj.(props{ii})); % not sure if base or caller better, we'll see...
                    end
                end
                
            end
        end
    end

    methods (Access = private)
        function msgPrinter(obj,str)
            fprintf(str);
        end
    end
end





