function GUI
% GUI for selection of the HOT and COLD anchor pixels. You can choose
% differen thematic maps for a better decision.

%  Create and then hide the UI as it is being constructed.
f = figure('Visible','off','Position',[10,10,1100,900]);

% Construct the components.
hredraw   = uicontrol('Style','pushbutton',...
             'String','Reset Axis','Position',[950,220,70,25],...
            'Callback',{@redrawbutton_Callback});
         
htext  = uicontrol('Style','text','String','Select Data',...
           'Position',[950,300,60,15]);
hpopup = uicontrol('Style','popupmenu',...
           'String',{'RGB','albedo','NDVI','LAI','Ts','Rn','G','Rn-G','rah','ux','Zom','H','ET'},...
           'Position',[950,270,100,25],...
           'Callback',@popup_menu_Callback);

ha = axes('Units','pixels','Position',[100,100,828,750]);

align([hredraw,htext,hpopup],'Center','None');


% Initialize the UI.
% Change units to normalized so components resize automatically.
f.Units = 'normalized';
ha.Units = 'normalized';
hredraw.Units = 'normalized';
htext.Units = 'normalized';
hpopup.Units = 'normalized';

% Get the data to plot.
RGB=evalin('base','RGB');
albedo=evalin('base','albedo');
NDVI=evalin('base','NDVI');
LAI=evalin('base','LAI');
Ts=evalin('base','Ts');
Rn=evalin('base','Rn');
G=evalin('base','G');
Rn_G=Rn-G;
Zom=evalin('base','Zom');
ux=evalin('base','ux');
rah=evalin('base','rah');
H=evalin('base','H');
ET=evalin('base','ET');

%load colormap file
handles=load('cmap.mat');

%set color ranges for each thematic map.
handles.colormaprange{1}=[0,1];
handles.colormaprange{2}=[prctile(prctile(albedo,5),5),prctile(prctile(albedo,95),95)];
handles.colormaprange{3}=[-1,1];
handles.colormaprange{4}=[0,prctile(prctile(LAI,95),95)];
handles.colormaprange{5}=[prctile(prctile(Ts,5),5),prctile(prctile(Ts,95),95)];
handles.index=1;


% Create a plot in the axes.
current_data = RGB;
imagesc(current_data);
axis equal;
colorbar;
colormap(handles.cmap_RGB);

% Assign a name to appear in the window title.
f.Name = 'Map Show GUI';


% Move the window to the center of the screen.
movegui(f,'center');
f.Visible = 'on';
%  Pop-up menu callback. Read the pop-up menu Value property to
%  determine which item is currently displayed and make it the
%  current data. This callback automatically has access to 
%  current_data because this function is nested at a lower level.
   function popup_menu_Callback(source,eventdata) 
      % Determine the selected data set.
      str = source.String;
      val = source.Value;
      % Set current data to the selected data set.
      tmp=gca;
      XLim=tmp.XLim;
      YLim=tmp.YLim;
      switch str{val};
        case 'RGB' 
         current_data = RGB;
         handles.index=1;
         colormap(handles.cmap_RGB);
        case 'albedo' 
         current_data = albedo;
         handles.index=2;
         colormap(handles.cmap_albedo);
        case 'NDVI' 
         current_data = NDVI;
         handles.index=3;
         colormap(handles.cmap_NDVI);
        case 'LAI' 
         current_data = LAI;
         handles.index=4;
         colormap(handles.cmap_LAI);
        case 'Ts' 
         current_data = Ts;
         handles.index=5;
         colormap(handles.cmap_Ts);
        case 'Rn'
         current_data = Rn;
         handles.index=0;
         colormap(jet);
        case 'G'
         current_data = G;
         handles.index=0;
         colormap(jet);
         case 'Rn-G'
         current_data = Rn_G;
         handles.index=0;
         colormap(jet);
        case 'Zom'
         current_data = Zom;
         handles.index=0;
         colormap(jet);
        case 'ux'
         current_data = ux;
         handles.index=0;
         colormap(jet);
        case 'rah'
         current_data = rah;
         handles.index=0; 
         colormap(jet);
        case 'H'
         current_data = H;
         handles.index=0;
         colormap(jet);
        case 'ET'
         current_data = ET;
         handles.index=0;
         colormap(flip(jet,1));
      end
      
      imagesc(current_data);
      axis equal;
      axis([XLim(1) XLim(2) YLim(1) YLim(2)]);
      colorbar;
      if handles.index>0;caxis(handles.colormaprange{handles.index});end;
   end
     
   function redrawbutton_Callback(source,eventdata,x,y) 
        imagesc(current_data);
        axis equal;
        colorbar;
        if handles.index>0;caxis(handles.colormaprange{handles.index});end;
   end

end