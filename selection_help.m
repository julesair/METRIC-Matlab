function pixels = selection_help(NDVI,albedo,Ts,mask,SUN_ELEVATION)
pixels=logical(ones(size(NDVI)));
pixels(mask==1)=0;
NDVIlim=prctile(NDVI(:),95);
pixels(NDVI<NDVIlim)=0;
Tslim=prctile(Ts(pixels),20);
pixels(Ts>Tslim)=0;
Ts_mean=mean(Ts(pixels));pixels(Ts>Ts_mean+0.2)=0;
% pixels(Ts<Ts_mean-0.2)=0;
albedo_lim=0.001343*SUN_ELEVATION+0.3281*exp(-0.0188*SUN_ELEVATION);
pixels(albedo>albedo_lim+0.2)=0;
pixels(albedo<albedo_lim-0.2)=0;
end
