function [landsat] = load_landsat7(datapath)
%IN: path to tar.gz file of landsat 7ETM+ data
%OUT: struct "landsat", containing an image for each band, georeference,
%serial date and time, sun azimuth and elevation.

try
%% Unpack Zip file and read images
    if exist('tmp')>0
        rmdir('tmp', 's');
    end
    mkdir tmp\;
    cd tmp\;
    filename = untar(datapath);
    gap_mask=0;

    Bandindex=[1 2 3 4 5 6 7 8];
    Bandname={'B1','B2','B3','B4','B5','_1','_2','B7'};
    for i=1:length(filename)
        [rn,cn]=find(strcmp(Bandname,filename{i}(end-5:end-4)));
        if ~isempty(cn)
            [A,R] = geotiffread(filename{i});
            landsat.A{Bandindex(cn)}=A;
            if cn==1;landsat.R=R;end;
        elseif filename{i}(end-6:end)=='MTL.txt';
            fID=fopen(filename{i});
            text=textscan(fID,'%s');
            fclose(fID);
        elseif filename{i}(1:8)=='gap_mask'
            gaps_mask =1;
        end
    end;


%% Read MTL file and pick out relevant information
    line=find(strcmp('SUN_AZIMUTH',text{1,1}))+2;
    landsat.SUN_AZIMUTH=str2double(text{1,1}(line));

    line=find(strcmp('SUN_ELEVATION',text{1,1}))+2;
    landsat.SUN_ELEVATION=str2double(text{1,1}(line));

    line=find(strcmp('DATE_ACQUIRED',text{1,1}))+2;
    landsat.DATE=datenum(text{1,1}(line),'yyyy-mm-dd');

    line=find(strcmp('SCENE_CENTER_TIME',text{1,1}))+2;
    timeshift=datenum('08','HH')-datenum('00','HH');
    landsat.TIME=datenum(text{1,1}{line}(2:9),'HH:MM:SS')+timeshift;

    line=find(strcmp('RADIANCE_MULT_BAND_1',text{1,1}));
    landsat.GAIN(1)=str2double(text{1,1}(line+2));
    line=find(strcmp('RADIANCE_MULT_BAND_2',text{1,1}));
    landsat.GAIN(2)=str2double(text{1,1}(line+2));
    line=find(strcmp('RADIANCE_MULT_BAND_3',text{1,1}));
    landsat.GAIN(3)=str2double(text{1,1}(line+2));
    line=find(strcmp('RADIANCE_MULT_BAND_4',text{1,1}));
    landsat.GAIN(4)=str2double(text{1,1}(line+2));
    line=find(strcmp('RADIANCE_MULT_BAND_5',text{1,1}));
    landsat.GAIN(5)=str2double(text{1,1}(line+2));
    line=find(strcmp('RADIANCE_MULT_BAND_6_VCID_1',text{1,1}));
    landsat.GAIN(6)=str2double(text{1,1}(line+2));
    line=find(strcmp('RADIANCE_MULT_BAND_6_VCID_2',text{1,1}));
    landsat.GAIN(7)=str2double(text{1,1}(line+2));
    line=find(strcmp('RADIANCE_MULT_BAND_7',text{1,1}));
    landsat.GAIN(8)=str2double(text{1,1}(line+2));

    line=find(strcmp('RADIANCE_ADD_BAND_1',text{1,1}));
    landsat.BIAS(1)=str2double(text{1,1}(line+2));
    line=find(strcmp('RADIANCE_ADD_BAND_2',text{1,1}));
    landsat.BIAS(2)=str2double(text{1,1}(line+2));
    line=find(strcmp('RADIANCE_ADD_BAND_3',text{1,1}));
    landsat.BIAS(3)=str2double(text{1,1}(line+2));
    line=find(strcmp('RADIANCE_ADD_BAND_4',text{1,1}));
    landsat.BIAS(4)=str2double(text{1,1}(line+2));
    line=find(strcmp('RADIANCE_ADD_BAND_5',text{1,1}));
    landsat.BIAS(5)=str2double(text{1,1}(line+2));
    line=find(strcmp('RADIANCE_ADD_BAND_6_VCID_1',text{1,1}));
    landsat.BIAS(6)=str2double(text{1,1}(line+2));
    line=find(strcmp('RADIANCE_ADD_BAND_6_VCID_2',text{1,1}));
    landsat.BIAS(7)=str2double(text{1,1}(line+2));
    line=find(strcmp('RADIANCE_ADD_BAND_7',text{1,1}));
    landsat.BIAS(8)=str2double(text{1,1}(line+2));

%% Create mask for pixels without observation
%Landsat Tile border & SLC-OFF Stripes
    mask=logical(ones(size(landsat.A{1})));

    if gap_mask==1
        cd gap_mask\
        list = dir;
        for i=1:8
            filename = gunzip(list(i+2).name);
            [A,R] = geotiffread(filename{1});
            mask = (A & mask);
        end
        cd('..\');
     else
        for i=1:8
            mask = (~landsat.A{i}==0 & mask);
        end 
    end
   mask=~mask;
   landsat.mask = mask;
   cd ..
 
catch
    disp('Error in load_landsat7')
    keyboard;
end
end


