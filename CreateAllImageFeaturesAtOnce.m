function CreateAllImageFeaturesAtOnce(imageDirectory, resultPath)

	% Construct the database using all the inputs

	addpath('sort_nat');
	addpath('gist');
	addpath('tinyimage');
	
	directoryList = dir(imageDirectory);	
	isub = [directoryList(:).isdir]; % returns logical vector
	folderNames = {directoryList(isub).name}';
	folderNames(ismember(folderNames,{'.','..'})) = [];
	
	dirSize = length(folderNames);
	
	for inx=1:dirSize
    
		dirName = folderNames(inx); % Input image name
		path = imageDirectory;        
		dirPath = [path dirName{1} '/']; % Construct the full path of the image        
	
		imagePath = dirPath;
		
		fileDir = dir([resultPath 'AllCandidates-' dirName{1} '*.mat']);	
				
		if(exist([resultPath fileDir.name], 'file') == 2)
			%disp([resultPath fileDir.name]);
			disp(['Skipping :' fileDir.name])
			continue;
		end		
		
		disp(' ');
		disp(['Processing:' imagePath '...']);
		disp(' ');
		disp(['Remaining:' num2str(dirSize - inx)]);		

		param.imageSize = 512;
		param.orientationsPerScale = [8 8 8 8];
		param.numberBlocks = 4;
		param.fc_prefilt = 4;

		width = 32; 
		height = 32;

		inputImageList = dir([imagePath '*.jpg']);
		imageCount = length(inputImageList);
		time = datestr(now,30);
		AllCandidatesRaw = struct();
		AllCandidates = struct();
		%disp('Starting process...');    
		disp(['Computing data for ' num2str(imageCount) ' items...']);
		tic;
		fileName = [];
		idx = [];

		parfor inx=1:imageCount    
				imageFileName = inputImageList(inx).name; % Input image name     
				imageFullDataPath = strcat(imagePath, imageFileName); % Construct the full path of the image
				
				try            
					image = imread(imageFullDataPath); % Check if image is ok.
					fileName = strrep(imageFileName, '.jpg', '');
					
					fileNameParameterArray = textscan(fileName, '%s', 'delimiter', '_'); % Split string
					
					latitude = fileNameParameterArray{1}{4};
					longitude = fileNameParameterArray{1}{5};
					
					%M = dlmread([csvPath fileName '.csv'], ';', 0, 0);
					%disp(M);
					%C = num2cell(M);
					%latitude = C{1} * 10; % Latitude
					%longitude = C{2} * 10; % Longitude
					[gist, ~] = ComputeGist(image, param);
					tinyImage = ComputeTinyImage(image, width, height);        
				catch e
					%skip file
					idx = [idx inx];
					continue;
					%rethrow(e);
				end
				
				AllCandidatesRaw(inx).Id = fileName;
				AllCandidatesRaw(inx).Latitude = str2double(latitude);
				AllCandidatesRaw(inx).Longitude = str2double(longitude);
				AllCandidatesRaw(inx).Gist = gist'; % transpose of gist matrix
				AllCandidatesRaw(inx).GistScore = 0;
				AllCandidatesRaw(inx).TinyImage = tinyImage;
				AllCandidatesRaw(inx).TinyImageScore = 0;        
				AllCandidatesRaw(inx).JointScore = 0;
				AllCandidatesRaw(inx).Image = [];
				AllCandidatesRaw(inx).MatchScore = 0;
		end
		 
		AllCandidatesRaw(idx) = []; % remove failed ids
		AllCandidates = AllCandidatesRaw;
			 
		toc;
		fileName = [resultPath 'AllCandidates-' dirName{1} '-' time '.mat'];     
		save(fileName, 'AllCandidates');
	
	disp(['Directory:' imagePath ' completed...']);
	
	end
    
	disp('Completed successfuly!');
 
end