function GUI
% GUI for selection of the HOT and COLD anchor pixels. You can choose
% differen thematic maps for a better decision.

%  Create and then hide the UI as it is being constructed.
f = figure('Visible','off','Position',[10,10,1100,900]);

% Construct the components.
hselectHOT   = uicontrol('Style','pushbutton','ForegroundColor','red',...
             'String','Select HOT Pixel','Position',[950,140,120,25],...
            'Callback',{@selectHOTbutton_Callback});
        
hselectCOLD   = uicontrol('Style','pushbutton','ForegroundColor','blue',...
             'String','Select COLD Pixel','Position',[950,170,120,25],...
            'Callback',{@selectCOLDbutton_Callback});        

hredraw   = uicontrol('Style','pushbutton',...
             'String','Reset Axis','Position',[950,220,70,25],...
            'Callback',{@redrawbutton_Callback});
         
htext  = uicontrol('Style','text','String','Select Data',...
           'Position',[950,300,60,15]);
hpopup = uicontrol('Style','popupmenu',...
           'String',{'RGB','albedo','NDVI','LAI','Ts','COLD candidates'},...
           'Position',[950,270,100,25],...
           'Callback',@popup_menu_Callback);

ha = axes('Units','pixels','Position',[100,100,828,750]);

align([hredraw,htext,hpopup,hselectHOT,hselectCOLD],'Center','None');


% Initialize the UI.
% Change units to normalized so components resize automatically.
f.Units = 'normalized';
ha.Units = 'normalized';
hredraw.Units = 'normalized';
htext.Units = 'normalized';
hpopup.Units = 'normalized';
hselectHOT.Units = 'normalized';
hselectCOLD.Units = 'normalized';

% Get the data to plot.
RGB=evalin('base','RGB');
albedo=evalin('base','albedo');
NDVI=evalin('base','NDVI');
LAI=evalin('base','LAI');
Ts=evalin('base','Ts');
candidates=evalin('base','candidates');

%load colormap file
handles=load('cmap.mat');

%set color ranges for each thematic map.
handles.colormaprange{1}=[0,1];
handles.colormaprange{2}=[prctile(prctile(albedo,5),5),prctile(prctile(albedo,95),95)];
handles.colormaprange{3}=[-1,1];
handles.colormaprange{4}=[0,prctile(prctile(LAI,95),95)];
handles.colormaprange{5}=[prctile(prctile(Ts,5),5),prctile(prctile(Ts,95),95)];
handles.colormaprange{6}=[0,1];
handles.index=1;


% Create a plot in the axes.
current_data = RGB;
hHOT=plot(1,1);
hCOLD=plot(1,1);
imagesc(current_data);
axis equal;
cH=evalin('base','cH');
cC=evalin('base','cC');
hold on;
if cH(1)>-1;hHOT=plot(cH(1),cH(2),'*','Color','red');end
if cC(1)>-1;hCOLD=plot(cC(1),cC(2),'*','Color','blue');end
colorbar;
colormap(handles.cmap_RGB);

% Assign a name to appear in the window title.
f.Name = 'Anchor Pixel Selection GUI';


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
         colormap(ha,handles.cmap_RGB);
      case 'albedo' 
         current_data = albedo;
         handles.index=2;
         colormap(ha,handles.cmap_albedo);
      case 'NDVI' 
         current_data = NDVI;
         handles.index=3;
         colormap(ha,handles.cmap_NDVI);
      case 'LAI' 
         current_data = LAI;
         handles.index=4;
         colormap(ha,handles.cmap_LAI);
      case 'Ts' 
         current_data = Ts;
         handles.index=5;
         colormap(ha,handles.cmap_Ts);
       case 'COLD candidates' 
         current_data = candidates;
         handles.index=6;
         colormap(ha,[0.2081,0.1663,0.5292;0.9763,0.9831,0.0538]);
      end
      
      imagesc(current_data);
      axis equal;
      axis([XLim(1) XLim(2) YLim(1) YLim(2)]);
      cH=evalin('base','cH');
      cC=evalin('base','cC');
      hold on;
      if cH(1)>-1;hHOT=plot(cH(1),cH(2),'*','Color','red');end
      if cC(1)>-1;hCOLD=plot(cC(1),cC(2),'*','Color','blue');end
      colorbar;
      caxis(handles.colormaprange{handles.index});
      hold off;
   end
     
   function redrawbutton_Callback(source,eventdata,x,y) 
        imagesc(current_data);
        axis equal;
        colorbar;
        caxis(handles.colormaprange{handles.index});
        cH=evalin('base','cH');
        cC=evalin('base','cC');
        hold on;
        if cH(1)>-1;hHOT=plot(cH(1),cH(2),'*','Color','red');end
        if cC(1)>-1;hCOLD=plot(cC(1),cC(2),'*','Color','blue');end
        hold off;
   end

    function selectHOTbutton_Callback(source,eventdata) 
        [x,y]=myginput(1,'crosshair');
        assignin('base', 'cH', [x,y]);
        cC=evalin('base','cC');
        hold on;
        delete(hHOT);
        delete(hCOLD);
        hHOT=plot(x,y,'*','Color','red');
        if cC(1)>-1;hCOLD=plot(cC(1),cC(2),'*','Color','blue');end
        hold off;
    end

    function selectCOLDbutton_Callback(source,eventdata) 
        [x,y]=myginput(1,'crosshair');
        assignin('base', 'cC', [x,y]);
        cH=evalin('base','cH');
        hold on;
        delete(hCOLD);
        delete(hHOT);
        hCOLD=plot(x,y,'*','Color','blue');
        if cH(1)>-1;hHOT=plot(cH(1),cH(2),'*','Color','red');end
        hold off;
    end


end