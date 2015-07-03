function [settings] = LoadSettings(fileName)

	% Load settings from ini file. 
	% Input : filename - name of the file
	%
	% Output : settings - a struct containing key value pairs

	addpath('lib/ini2struct');    
	settings = ini2struct(fileName);
end

