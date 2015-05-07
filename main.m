%% 0. Clear Workspace to avoid interference
disp('Will clear your current workspace in ....')
disp('5');pause(1);disp('4');pause(1);disp('3');pause(1);disp('2');pause(1);disp('1');pause(1);disp('Start now...');
clear all;

%% 1. Set path variables
%add library for functions and gui to search path
addpath('lib','gui');
%path- and filename to landsat image -> must be an .tar.gz file
filename_landsat='D:\Landsat\L7 ETM_ SLC-off _2003-present_\withPAN\LE71230352013332EDC00.tar.gz';

%path- and filename to meteodata in .mat format.
filename_meteodata='C:\Users\Jules\Dropbox (hydrosolutions)\hydrosolutions_jules\Project Guantao\data\meteostations\guantao\guantao.mat';

%path- and filename to prm file in .mat format.
filename_prm='C:\Users\Jules\Dropbox (hydrosolutions)\hydrosolutions_jules\Project Guantao\METRIC Matlab\prm.mat';
%% 2. Load necessary files and parameters into workspace
matexist=exist('landsat.mat');
if matexist>0
    load('landsat.mat');
elseif filename_landsat(end-27:end-25) == 'LE7'
    landsat=load_landsat7(filename_landsat); 
    %save('landsat.mat','landsat');
elseif filename_landsat(end-27:end-25) == 'LC8'
    landsat=load_landsat8(filename_landsat);
    %save('landsat.mat','landsat');
else
    disp('no valid landsat dataset could be found')
    keyboard;
end;

load(filename_prm);
load(filename_meteodata);

% copy K1,K2 for surface temperature calculation in case of landsat 7
if ~isfield(landsat,'K')
    landsat.K(1)=prm.K1;
    landsat.K(2)=prm.K2;
end

clear matexist 
%% 3. Search meteodata observation corresponding to landsat aquisition date
temp=find(meteodata.DATE==landsat.DATE);
if ~isempty(temp)
    prm.m_i=temp;
else
    prm.m_i=NaN;
    disp('WARNING: No meteodata for landsat date available. Check you meteodata!')
end
clear temp;

%% 4. Create true color image
RGB=(cat(3, landsat.A{3}, landsat.A{2}, landsat.A{1})); %true color image
RGB=imadjust(RGB,stretchlim(RGB),[0 0 0;1 0.9 0.9])-40;

%% 5. Convert digital number image [1-255] to radiance value [W/(m2*ster*micrometer)]
% for reference, see: http://landsat.usgs.gov/how_is_radiance_calculated.php

for i=1:length(landsat.A)
    landsat.A{i}=single(landsat.A{i});
    landsat.A{i}=landsat.GAIN(i)*landsat.A{i}+landsat.BIAS(i);
    landsat.A{i}(landsat.A{i}<0) = 0; %set negative radiance to zero
    landsat.A{i}(landsat.mask) = NaN;
end

%% 6. Compute necessary maps from landsat bands

%albedo [dimensionless]
albedo=albedo(landsat,prm,meteodata.VapP(prm.m_i),meteodata.LONLATELEV(3));

%free memory, delete landsat bands which are not necessary anymore
landsat.A{1}=[];landsat.A{2}=[];landsat.A{5}=[];landsat.A{1}=[];landsat.A{8}=[];

%normalized differenced vegetation & leaf area index [dimensionless]
NDVI=vegetation_index('NDVI',landsat.A{3},landsat.A{4},landsat.mask);
LAI=vegetation_index('LAI',landsat.A{3},landsat.A{4},landsat.mask,prm.L);

%flag water
%landsat.mask(NDVI<-0.1)=1;

%broadband surface thermal emissivity [dimensionless]
[epsilon0, epsilonNB]=thermal_emissivity(LAI,albedo);

%surface temperature [°K]
Ts=surface_temperature(landsat,epsilonNB);

%remove landsat data from workspace, free memory
landsat = rmfield(landsat,'A');

%% 7. Anchor Pixel selection
candidates=selection_help(NDVI,albedo,Ts,landsat.mask,landsat.SUN_ELEVATION);
if ~exist('cH') & ~exist('cC')
    cC=[-1,-1];cH=[-1,-1];
else
    cC=fliplr(round(cC));cH=fliplr(round(cH));
end;

GUI;
t=0;
while cC(1)==-1 || cH(1)==-1 || t==0
    sprintf(['Please choose the HOT and COLD anchor pixels.\n',...
        'When finished, close the window and type "return" \n',...
        'to proceed. Otherwise type "dbquit" to exit this script\n',...
        'You can reopen the selection GUI by calling GUI()'])
    keyboard;
    t=1;
end

%round coordinates to integer and flip because matrices and plots have not the same
%axis....(or debug for ever....)
cC=fliplr(round(cC));cH=fliplr(round(cH));

%% 8. 1st Part of Surface Energy Balance Computation

%incoming shortwave radiation [W/m2]
Rs=shortwave_radiation(prm,landsat.DATE,landsat.SUN_ELEVATION,meteodata.LONLATELEV(3));

%outgoing and incoming longwave radiation [W/m2]
[RLdown, RLup] = longwave_radiation(meteodata.VapP(prm.m_i),cC,epsilon0,Ts,meteodata.LONLATELEV(3));

%Net radiation flux at surface [W/m2]
Rn = (1-albedo) .* Rs + RLdown - RLup - (1-epsilon0) .* RLdown;

%Soil heat flux [W/m2]
G = soil_heatflux(albedo,NDVI,Ts,Rn,LAI);

%% 9. Iteration loop for computation of sensible heat flux H

% Calculate initial values for aerodynamic resistance rah [s/m] and 
% Friction velocity [m/s]
% Calculate roughness length Zom [m] and windspeed at height
% 200m above ground [m] from meteodata.
[rah, ux, u200, Zom]=initial_rah(landsat,prm,meteodata,LAI,Ts);

%Calculate ETr [mm/s] at Cold anchor pixel from meteodata
lambda=(2.501-0.00236*(Ts-273.15))*10^6; %latent heat of vaporization [J/kg]
dRnG_COLD=Rn(cC(1),cC(2))-G(cC(1),cC(2));
ETr = 2*ETreference(meteodata,prm.m_i,landsat.TIME,lambda(cC(1),cC(2)),dRnG_COLD,rah(cC(1),cC(2)));
rho_a=1.224*(~landsat.mask);

%iteration loop:
i=1; %set count to 1
while (i<7)
    [H, rho_a, dT_hot, dT_cold] = calibrate(Rn,G,Ts,rah,cH,cC,ETr,lambda,meteodata.LONLATELEV(3),rho_a);
    disp(dT_hot);
    disp(dT_cold);
    [rah] = stability_correction(Ts,H,ux,u200,Zom,rho_a);
    i=i+1;
    rah_COLD(i)=rah(cC(1),cC(2));
    delta_mean(i)=abs(rah_COLD(i)-rah_COLD(i-1));
end

[H, rho_a, dT_hot, dT_cold] = calibrate(Rn,G,Ts,rah,cH,cC, ETr,lambda,meteodata.LONLATELEV(3),rho_a);

ET= 3600./lambda.*(Rn - G - H);
ETrf=ET/ETr;
ETrf(ETrf>3)=3;
ETrf(ETrf<-1)=-1;