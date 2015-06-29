function [averageEstimationError] = DemoApp(mode, parameters)
	
	% Geolocalize given query scene(s) using a reference dataset.
	%
	% Inputs:	mode - only test mode for now
	% 			parameters - simply a struct with the same fields as settings. You can set any field as you wish.
	%
	% Outputs:	averageEstimationError - average estimation error for given scene(s)
		
	addpath(genpath('lib'));	 % Environment variables.	
	Settings = LoadSettings('data/settings.ini'); 	% Load default settings.
	
	if(strcmp(mode,'test') && exist('parameters','var')) % In test mode, if provided override default settings
		parameterFields = fieldnames(parameters); 
		for loopIndex = 1:numel(parameterFields)
			if(isfield(Settings,parameterFields{loopIndex})) % If there is a same field in Settings
				Settings.(parameterFields{loopIndex}) = parameters.(parameterFields{loopIndex});
			end
		end
	end
	
	Settings.InitialResultPath = Settings.ResultPath; % Used to reset to initial folder    
	Results = struct('QueryImageName', [], 'QueryImageLatitude', 0, 'QueryImageLongitude', 0, 'EstimatedLatitude', 0, 'EstimatedLongitude', 0, 'EstimationError', 0, 'ComputationTime', 0, 'Success', 0, 'TimesBetterThanChance', 0);
    JointResults = struct('QueryImageName', [], 'EstimationError', 0, 'ComputationTime', 0, 'Success', 0, 'ByChanceDistanceError', 0, 'TimesBetterThanChance', 0);
	baseFolder = [datestr(now,30) '-' Settings.ExperimentName] ;    
    mkdir(Settings.ResultPath, baseFolder); % Create a base directory to save the results for the input.
    disp('Starting Geolocalization...');
	AllItems = LoadPreRequisites(Settings);
	
    if(Settings.SizeCap ~= 0 && length(AllItems) > Settings.SizeCap)
		r = randi(length(AllItems), Settings.SizeCap, 1); % Get random integers
		AllItems = AllItems(r); % Reduce dataset size by selecting random items from dataset, for size effect in the paper.
		clear r;	
    end
     
    if(strcmp(mode,'test')) % Test mode
		inputImageList = dir([Settings.QueryDataPath '*.jpg']); % Get query image list
		if isempty(inputImageList)
			error('Cannot find the query images.');
		end            
		[~,order] = sort_nat({inputImageList.name}); % Sort images in asc order.
		inputImageList = inputImageList(order);
		imageCount = length(inputImageList);
    end

    if(Settings.SequenceCap ~= 0 && imageCount > Settings.SequenceCap)
        imageCount = Settings.SequenceCap;
    end
    
    for imageIndex=1:imageCount
		start = clock;
        Settings.ResultPath = [Settings.InitialResultPath baseFolder '/']; % Set path to base folder      
        Results.QueryImageName = num2str(imageIndex);
        
		if(strcmp(mode, 'test')) % Test mode		
			%if(~strcmp(inputImageList(imageIndex).name, '0445.jpg')) % To test specific image. Comment o/w.
			% Settings.ResultPath = [Settings.InitialResultPath]; % Reset path       
			%	continue; 
			%end		
			disp(['Processing ' inputImageList(imageIndex).name]);
			imageFileName = inputImageList(imageIndex).name;
			imageFullPath = strcat(Settings.QueryDataPath, imageFileName); % Construct the full path of the image        
			queryImage = imread(imageFullPath); % Read image
			fileName = strrep(imageFileName, '.jpg', ''); % Strip file extension to obtain file name               
			fid = fopen([Settings.QueryDataPath fileName '.gps'], 'r'); % Read GPS data
			
			if fid <= 0
				error('Cannot read: %s', fileName);
			end
			
			tline = fgetl(fid);                
			fileNameParameterArray = textscan(tline, '%s', 'delimiter', ' '); % Split string					
			lat = fileNameParameterArray{1}{1};
			lon = fileNameParameterArray{1}{2};                
			fclose(fid);			
			Settings.QueryImageLatitude = str2double(lat);
			Settings.QueryImageLongitude = str2double(lon);
			Results.QueryImageName = fileName;			
		else
			queryImage = keyFrames(imageIndex);
		end
		
        mkdir(Settings.ResultPath, Results.QueryImageName); % Create a directory to save individual results.
        Settings.ResultPath = [Settings.ResultPath Results.QueryImageName '/'];
        [latitude, longitude, FirstCandidates, SecondCandidates, ThirdCandidates, FirstCandidateOutliers, SecondCandidateOutliers, AllCandidates] = RetrieveAlignPredict(queryImage, AllItems, Settings);
        % Display Results
        disp('---------RESULTS--------------------------------------------------------------------------------------');
        disp(['Estimated location for image ' Results.QueryImageName]);
        disp(['Latitude:' num2str(latitude)]);
        disp(['Longitude:' num2str(longitude)]);
        computationTime = etime(clock, start);
        disp(['The computation took ' num2str(computationTime) ' seconds on the ' num2str(size(queryImage, 2)) 'x' num2str(size(queryImage, 1)) ' image']);
		
		if(strcmp(mode,'test')) % Test mode
			latlongQueryImage = [Settings.QueryImageLatitude Settings.QueryImageLongitude];
			Results.EstimationError = lldistkm(latlongQueryImage, [latitude longitude]); % Calculate distance between estimated location and query location
			
			if(Results.EstimationError < Settings.SuccessDistance)
				Results.Success = 1;
				disp('Estimation succeeded...');
			else
				Results.Success = 0;
				disp('Estimation failed...');
			end

			disp(['Estimation error:' num2str(Results.EstimationError) 'km']);                
			disp('Please wait, calculating better than chance metric...');  
			[RandomCandidates, latitudeRandom, longitudeRandom] = EstimateByChance(AllCandidates, length(ThirdCandidates), Settings);               
			estimatedDistanceForRandomSelection = lldistkm(latlongQueryImage, [latitudeRandom longitudeRandom]); % Calculate distance between the query and the estimated location 
			Results.TimesBetterThanChance = estimatedDistanceForRandomSelection / Results.EstimationError;     
			disp(['Our results are better than chance by ' num2str(Results.TimesBetterThanChance) ' times']);
		end
        disp('--------------------------------------------------------------------------------------------------------');
		
		if(Settings.DisplayResults == 1 || Settings.ExportResults == 1)
			disp('Adjusting points..');
			[AllCandidates, FirstCandidates, SecondCandidates] = AdjustCandidateScoresForPlotting(AllCandidates, FirstCandidates, SecondCandidates);
		end
		
		% Plot results
        if(Settings.DisplayResults == 1)
            disp('Plotting results..');
			DisplayAndSaveResults(queryImage, FirstCandidates, SecondCandidates, ThirdCandidates, RandomCandidates, AllCandidates, FirstCandidateOutliers, SecondCandidateOutliers, Settings); % Display and save results altogether
			close all;
        end

        Results.QueryImageLatitude = Settings.QueryImageLatitude; % Save results
        Results.QueryImageLongitude = Settings.QueryImageLongitude;
        Results.EstimatedLatitude = latitude;
        Results.EstimatedLongitude = longitude;
        Results.ComputationTime = computationTime;
		
		if(Settings.ExportResults == 1)			
			save([Settings.ResultPath 'Settings.mat'], 'Settings');
			save([Settings.ResultPath 'Results.mat'], 'Results');
			save([Settings.ResultPath 'FirstCandidates.mat'], 'FirstCandidates');
			save([Settings.ResultPath 'SecondCandidates.mat'], 'SecondCandidates');
			save([Settings.ResultPath 'ThirdCandidates.mat'], 'ThirdCandidates');
			save([Settings.ResultPath 'RandomCandidates.mat'], 'RandomCandidates');
			save([Settings.ResultPath 'FirstCandidateOutliers.mat'], 'FirstCandidateOutliers');
			save([Settings.ResultPath 'SecondCandidateOutliers.mat'], 'SecondCandidateOutliers');
			save([Settings.ResultPath 'AllCandidates.mat'], 'AllCandidates');
			close all;
		end
        
        % Set joint results        
        JointResults(imageIndex).QueryImageName = Results.QueryImageName;  
        JointResults(imageIndex).EstimationError = Results.EstimationError;
        JointResults(imageIndex).ByChanceDistanceError = estimatedDistanceForRandomSelection;
        JointResults(imageIndex).ComputationTime = Results.ComputationTime;
        JointResults(imageIndex).TimesBetterThanChance = Results.TimesBetterThanChance;
        JointResults(imageIndex).Success = Results.Success;
    end
	
    Settings.ResultPath = [Settings.InitialResultPath baseFolder '/']; % Reset path      	
	save([Settings.ResultPath 'JointResults.mat'], 'JointResults');
	struct2csv(JointResults, [Settings.ResultPath 'joint-recall-results-' Settings.ExperimentName '.csv']); % Save as csv file	
	averageEstimationError = mean([JointResults.EstimationError]);   
    disp('Geolocalization completed successfuly!');
end