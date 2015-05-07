function out = vegetation_index(mode,Band3,Band4,mask,varargin)
% Calculates either NDVI or LAI from Landsat Band 3&4
% CALL:     vegetation_index(mode,Band3,Band4,mask,L(optional)) 
% INPUT:    mode = 'NDVI' or 'LAI' 
%           Band3,Band4: n x m matrices
%           mask: logical matrix of size Band 3&4, true cells are set NaN
%           L : only for LAI, parameter for SAVI soil adjustement [0...1]

switch mode
    
    case 'NDVI'
        NDVI = (Band4-Band3) ./ (Band4+Band3);
        NDVI(mask) = NaN;
        out = NDVI;
        
    case 'LAI'
        if isempty(varargin{1});disp('Parameter L is necessary for LAI');end;
        L = varargin{1};
        L_matrix = L*(~mask); %create matrix with value L
        
        %Soil adjusted vegetation index
        SAVI = (1+L)*(Band4-Band3) ./ (L_matrix+Band4+Band3);
        SAVI(SAVI>0.69) = 0.69; %avoid complex numbers in LAI -> find better solution!
        
        %Leaf area index
        LAI = log((0.69-SAVI)/0.59)*-1/0.91;
        LAI(LAI>6) = 6; %limit LAI to 6 as proposed by METRIC
        LAI(LAI<0) = 0;%limit LAI to 0 -> non vegetated areas.
        LAI(mask) = NaN;
        out = LAI;
    otherwise
        disp('vegetation_index: choose either NDVI or LAI as mode')
end