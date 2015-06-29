function [latitude, longitude, FirstCandidates, SecondCandidates, ThirdCandidates, FirstCandidateOutliers, SecondCandidateOutliers, AllCandidates] = RetrieveAlignPredict(queryImage, AllCandidateItems, Settings)
	%
	%  Search query image against entire database and get the most likely geolocation estimate for the given image
	%
	% Inputs:	queryImage - the input image
	% 			AllCandidateItems - Entire database items
	%			Settings - Application wide settings used to store algorithm parameters, paths etc.
	%
	% Outputs:	latitude - Estimated latitude
	%			longitude - Estimated longitude
	%			FirstCandidates - Initial set of candidates with highest JointScore (GIST + Tiny Image)
	%			SecondCandidates - Candidates after outliers removed via FNR algorithm using JointScore  (GIST + Tiny Image)
	%			ThirdCandidates - Final set of candidates with best MatchScore and outliers removed via FNR algorithm using MatchScore (DSP)
	%			FirstCandidateOutliers - The removed outliers via FNR algorithm using JointScore
	%			SecondCandidateOutliers - The removed outliers via FNR algorithm using MatchScore (DSP)
	%			AllCandidates - Entire database items stripped from extra attributes
	
	AllCandidates = struct('Id', [], 'Latitude', 0, 'Longitude', 0, 'GistScore', 0, 'TinyImageScore', 0, 'JointScore', 0, 'MatchScore', 0);	
    [gist, ~] = ComputeGist(queryImage, Settings.GistParameters); % Compute gist of the image    
    tinyImage = ComputeTinyImage(queryImage, Settings.TinyImageWidth, Settings.TinyImageHeight); % Compute tinyimage of the image.
    
    disp(['Computing GIST and Tiny Image scores for ' num2str(length(AllCandidateItems)) ' images...']);    
    parfor k = 1: length(AllCandidateItems) % Compute gist and tiny image distances.
		AllCandidates(k).Id = AllCandidateItems(k).Id;
		AllCandidates(k).Latitude = AllCandidateItems(k).Latitude;
		AllCandidates(k).Longitude = AllCandidateItems(k).Longitude;
        AllCandidates(k).GistScore = slmetric_pw(single(gist)', single(AllCandidateItems(k).Gist), 'eucdist');
        AllCandidates(k).TinyImageScore = slmetric_pw(single(tinyImage), single(AllCandidateItems(k).TinyImage), 'eucdist');
		AllCandidates(k).JointScore = 0;
		AllCandidates(k).MatchScore = 0;
    end
	
	% Clear gist tinyImage AllCandidateItems;
    disp('Normalizing GIST and Tiny Image scores...');    
	GistScores = struct('Min', min([AllCandidates.GistScore]), 'Max', max([AllCandidates.GistScore]), 'Mean', mean([AllCandidates.GistScore])); % Compute gist and tiny image min/max/mean scores.
	TinyImageScores = struct('Min', min([AllCandidates.TinyImageScore]), 'Max', max([AllCandidates.TinyImageScore]), 'Mean', mean([AllCandidates.TinyImageScore]));
	
    parfor k = 1:length(AllCandidates)
        AllCandidates(k).GistScore = NormalizeData(AllCandidates(k).GistScore, GistScores.Min, GistScores.Max, GistScores.Mean, Settings.NormalizationMethod, Settings.Sigma);
        AllCandidates(k).TinyImageScore = NormalizeData(AllCandidates(k).TinyImageScore, TinyImageScores.Min, TinyImageScores.Max, TinyImageScores.Mean, Settings.NormalizationMethod, Settings.Sigma);
    end

    disp('Computing joint score...');
	J = bsxfun(@plus, bsxfun(@times, Settings.GistWeight, [AllCandidates.GistScore]), bsxfun(@times, Settings.TinyImageWeight, [AllCandidates.TinyImageScore]));
	J = num2cell(J);
	[AllCandidates.JointScore] = J{:};
    AllCandidates = nestedSortStruct(AllCandidates, 'JointScore');     
    FirstCandidates = AllCandidates(length(AllCandidates) - Settings.CandidateListSize + 1:length(AllCandidates)); % Select best N items via JointScore
	
    disp(['Removing furthest neighbors via JointScore, from ' num2str(length(FirstCandidates)) ' candidates...']);
	[SecondCandidates, FirstCandidateOutliers] = FurthestNeighbourRemoval(FirstCandidates, 'JointScore', Settings);	
	
	if(strcmp(Settings.MatchMethod, 'NONE'))	
		ThirdCandidates = SecondCandidates;
		SecondCandidateOutliers = FirstCandidateOutliers;		
	else
		disp(['Computing MatchScore via '  Settings.MatchMethod  '  for ' num2str(length(SecondCandidates)) ' candidates...']);		
		
		parfor q = 1: length(SecondCandidates) % Compute MatchScores.
			retreivedImage =  imread([Settings.ReferenceDataPath SecondCandidates(q).Id '.jpg']);
			SecondCandidates(q).MatchScore = ComputeMatchScore(queryImage, retreivedImage, Settings.MatchMethod, Settings);
		end
		
		disp('Normalizing MatchScore...');
		MatchScores = struct('Min', min([SecondCandidates.MatchScore]), 'Max', max([SecondCandidates.MatchScore]), 'Mean', mean([SecondCandidates.MatchScore])); % Compute MatchScore min/max/mean distances.
		
		parfor k = 1:length(SecondCandidates)
			SecondCandidates(k).MatchScore =  NormalizeData(SecondCandidates(k).MatchScore, MatchScores.Min, MatchScores.Max, MatchScores.Mean, Settings.NormalizationMethod, Settings.Sigma);
		end

		disp(['Removing furthest neighbors via MatchScore, from ' num2str(length(SecondCandidates)) ' candidates...']);
		[ThirdCandidates, SecondCandidateOutliers] = FurthestNeighbourRemoval(SecondCandidates, 'MatchScore', Settings);		
	end
	
	disp(['Making geolocation estimation from ' num2str(length(ThirdCandidates)) ' candidates...']);
    [latitude, longitude] = PredictLocation(ThirdCandidates, 'MatchScore', Settings);
end