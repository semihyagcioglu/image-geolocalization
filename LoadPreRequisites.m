function AllItems = LoadPreRequisites(parameters)

	% Load the prerequisites in order to run the main algorithm
	%
	% Inputs:	parameters- Application settings
	%
	% Outputs:	AllItems - Entire database items
	
	% Default variables
	Settings.AllItemsPath = '/data/features/';
	Settings.ReferenceDataPath = '/data/images/';
	Settings.QueryDataPath = '/data/query/';
	
	if(exist('parameters','var')) % If provided override default variables
		parameterFields = fieldnames(parameters); 
		for loopIndex = 1:numel(parameterFields)
			if(isfield(Settings,parameterFields{loopIndex})) % If there is a same field  in Settings
				Settings.(parameterFields{loopIndex}) = parameters.(parameterFields{loopIndex});
			end
		end   
	end
	
	run('dsp/vlfeat-0.9.17/toolbox/vl_setup.m'); % Prerequisite run for vlfeat library.	
	disp('Loading Features...');
	
	fileDir = dir([Settings.AllItemsPath 'AllCandidates*.mat']);
	%tic;
	for dinx = 1: length(fileDir)	
		file = load([Settings.AllItemsPath fileDir(dinx).name]);
		AllItems = [AllItems file.AllCandidates];
		clear file;
	end
	%toc;
	disp('Loading Finished...');
end