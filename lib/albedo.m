function out = albedo(landsat, prm, VapP, z)
% Calculates surface albedo from Landsat 7 bands 1,2,3,4,5,7
% CALL: surface_albedo(landsat, prm, VapP, z)
% INPUT: landsat: struct containing Bands in .A, .SUN_ELEVATION(Degree) and
%        .DATE(serial)
%        prm: struct containing predefined coefficients for METRIC 
%        VapP: Vapour Pressure [kPa] at scene
%        z: height of scene surface above sea level (soon replaced by DEM)
%
% see "At-Surface Reflectance and Albedo from Satellite for Operational
% Calculation of Land Surface Energy Balance, M.Tasumi, R.Allen, R.Trezza
% 2008

DOY=date2doy(landsat.DATE);
dr=1+0.033*cos(2*pi/365*DOY); % inverse of square of relative distance to earth
theta=(90-landsat.SUN_ELEVATION)/360*2*pi; %solar zenith angle
ea=VapP*0.1; %vapor pressure in kPa
Pair=101.3*((293-0.0065*z)/293)^5.26; %mean atmospheric pressure
W=0.14*ea*Pair+2.1; %precipitable water in the atmosphere

alpha=zeros(size(landsat.A{1}));

% for Landsat 7 bands 1,2,3,4,5,7
for i=[1,2,3,4,5,8]
    rho_t=pi/(prm.ESUN(i)*cos(theta)*dr)*landsat.A{i};
    
    x_in=(prm.C2(i)*Pair - prm.C3(i)*W - prm.C4(i)) / cos(theta);
    teta_in=prm.C1(i)*exp(x_in) + prm.C5(i);
    
    teta_out=prm.C1(i)*exp(prm.C2(i)*Pair-prm.C3(i)*W-prm.C4(i)) + prm.C5(i);
    
    k=prm.Cb(i)*(1-teta_in);
    rho_a=zeros(size(landsat.A{i}))+(landsat.A{i}>0)*k;
   
    rho_s=(rho_t-rho_a) / (teta_in*teta_out);
    
    alpha=alpha+rho_s*prm.wb(i);
end

alpha(find(alpha>1)) = 1; alpha(find(alpha<0)) = 0;
out=alpha;
