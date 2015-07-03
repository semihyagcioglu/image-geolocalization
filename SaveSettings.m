function SaveSettings(fileName, settings)

	% Save settings to an ini file. 
	% Input : filename - name of the file
	%
	% Output : settings - a struct containing key value pairs
	%
	% Example settings struct:
	% Settings.SizeCap = 1000;
	% Settings.SequenceCap = 5;
	% Settings.CandidateListSize = 100;
	% Settings.TinyImageWidth = 32;
	% Settings.TinyImageHeight = 32;
	% Settings.GistParameters.imageSize = 512;
	% Settings.GistParameters.orientationsPerScale = [8 8 8 8];
	% Settings.GistParameters.numberBlocks = 4;
	% Settings.GistParameters.fc_prefilt = 4;
	% Settings.GistWeight = 0.9;
	% Settings.TinyImageWeight = 1 - % Settings.GistWeight; % This is due to joint score calculations.
	% Settings.NormalizationMethod = 'EXP'; % 'EXP' or 'MAX'
	% Settings.Sigma = 1; % for exp normalization method
	% Settings.Epsilon = 0.1;
	% Settings.NearestNeighbourThreshold = 0.5;
	% Settings.NearestNeighbourNumber = 1;
	% Settings.PlottingMethod = 'TRIANGULATION'; %'INTERPOLATION'
	% Settings.MatchMethod = 'DSP'; % 'DSP' or 'SIFT' or 'NONE'
	% Settings.L2Ratio4SIFT = 1.5; 
	% Settings.QueryImageLatitude = 0;
	% Settings.QueryImageLongitude = 0;
	% Settings.ResultPath = 'results/single-runs/';
	% Settings.ExportResults = 0;
	% Settings.DisplayResults = 0;
	% Settings.SuccessDistance = 0.3; % If estimated location is within this radius, call it a success
	% Settings.ExperimentName = ['GIST-' num2str(% Settings.GistWeight) '-TINY-' num2str(% Settings.TinyImageWeight) '-' num2str(% Settings.MatchMethod)];
	% Settings.AllItemsPath = '/data/features/';
	% Settings.ReferenceDataPath = '/data/images/';
	% Settings.QueryDataPath = '/data/query/';

	addpath('lib/struct2ini');    
	struct2ini(fileName, settings);
end
