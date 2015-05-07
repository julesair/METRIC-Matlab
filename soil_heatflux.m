function G = soil_heatflux(albedo,NDVI,Ts,Rn,LAI)
% calculates Soil heat flux as per Bastiaanssen (1995)
% CALL: soil_heatflux(albedo,NDVI,Ts,Rn)
% INPUT: n x m matrices of albedo,NDVI,Ts (surface temperature) and
%        Rn(net radiation on surface)

G = (Ts-273.15).*(0.0038 + 0.0074*albedo).*(1-0.98*NDVI.^4).*Rn;
%G=0.5*Rn.*exp(-0.5*LAI);
G(NDVI<-0.2)=0.4*Rn(NDVI<-0.2); %flag for clear water
%G(Ts<277.15 & albedo>0.45)=0.5*Rn(Ts<277.15 & albedo>0.45); %flag for snow
G(G<0)=0;
end