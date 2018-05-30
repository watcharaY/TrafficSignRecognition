function varargout = sign_camera(varargin)
% SIGN_CAMERA MATLAB code for sign_camera.fig
%      SIGN_CAMERA, by itself, creates a new SIGN_CAMERA or raises the existing
%      singleton*.
%
%      H = SIGN_CAMERA returns the handle to a new SIGN_CAMERA or the handle to
%      the existing singleton*.
%
%      SIGN_CAMERA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SIGN_CAMERA.M with the given input arguments.
%
%      SIGN_CAMERA('Property','Value',...) creates a new SIGN_CAMERA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sign_camera_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sign_camera_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help sign_camera

% Last Modified by GUIDE v2.5 07-May-2018 12:40:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sign_camera_OpeningFcn, ...
                   'gui_OutputFcn',  @sign_camera_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before sign_camera is made visible.
function sign_camera_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sign_camera (see VARARGIN)

% Choose default command line output for sign_camera
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes sign_camera wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = sign_camera_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btn_opencam.
function btn_opencam_Callback(hObject, eventdata, handles)
% hObject    handle to btn_opencam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.

detector = vision.CascadeObjectDetector('2000_stage15_0.2.xml');
load elm_model.mat;
load gong.mat;% load เสียงของmatlab
p=audioplayer(y,Fs);
classTable={
    'unknow','right','dont','nurse','il100','il60','il80','io','ip','p10','p11','p12','p19','p23','stop','stopp','p3','p5'...,
    'p6','pg','ph4','ph4.5','ph5','pl100','pl120','pl20','pl30','pl40','pl5','pl50','pl60','pl70','pl80'...,
    'pm20','pm30','pm55','pn','pne','po','pr40','w13','w32','w55','w57','w59','wo'
};

cam = webcam();
%%ดึง value จาก popup and checkbox
dropdownCam = get(handles.popupmenu2,'String'); 
cam_Resolution = dropdownCam{get(handles.popupmenu2,'Value')};
switch cam_Resolution 
    case '1280x720'
        cam.Resolution = '1280x720';%ดูขนาด cam.AvailableResolutions
    case '640x480'
        cam.Resolution = '800x600';        
    case '800x600'
        cam.Resolution = '800x600';
    case '1600x896'
        cam.Resolution = '1600x896';
    case '1920x1080'
        cam.Resolution = '1920x1080';
end
%%
%cam.Resolution = '1280x720';%ดูขนาด cam.AvailableResolutions
%'640x480'    '160x120'    '176x144'    '320x240'    
% '352x288'    '800x600'    '960x720'    '1024x576'    
% '1280x720'    '1280x960'    '1392x768'    '1600x896' '1920x1080'
% cam=videoinput('winvideo',1,'MJPG_640x480');
cam_status_on=true;
axes(handles.axes1);
while cam_status_on
     %%ดึง value จาก popup and checkbox
        dropdown = get(handles.popupmenu1,'String'); 
        speak_language = dropdown{get(handles.popupmenu1,'Value')};
        
        CheckBoxMute=get(handles.check_mute,'Value');

        %%
    
    %videoFrame = getsnapshot(cam);
    videoFrame = imresize(snapshot(cam),0.4);
%     video = readFrame(v);
%     videoFrame=imresize(video,0.8);
    bboxes = step(detector,videoFrame);
    %image(videoFrame, 'Parent', handles.axes1);
    set(handles.axes1, 'Visible', 'off');
      
         
    numBox=size(bboxes,1);
    if numBox>0
        label_str=cell(numBox,1);
        label_sound=cell(1);
        
        for boxIndex=1:numBox
            bbox=bboxes(boxIndex,:);
            detectedRegions=imcrop(videoFrame,bbox);

            imgHOG=hogcalculator(detectedRegions);
            tempH_test=InputWeight*imgHOG';          
            tempH_test=tempH_test + BiasofHiddenNeurons;
            switch lower(ActivationFunction)
            case {'sig','sigmoid'}%%%%%%%% Sigmoid 
                H_test = 1 ./ (1 + exp(-tempH_test));          
            end
            
            TY=(H_test' * OutputWeight)';
            [x, label_index_actual]=max(TY);
            output=label(label_index_actual);%get sign classId
            
            if strcmp(speak_language,'Thai')
                label_str{boxIndex}=char(mapId2TypeString2TH(output+1));
                label_sound{boxIndex}=char(soundNameTH(output+1));
            elseif strcmp(speak_language,'English')
                label_str{boxIndex}=char(mapId2TypeString2EN(output+1));
                label_sound{boxIndex}=char(soundNameEN(output+1));
            end
            

            if numBox == 1 && ~strcmp(label_str,'notSign')%%%%%%% แก้error label_str ส่งค่าเกิน 1  ,,, ไม่ให้แสดงป้ายที่ notSign
                videoFrame = insertText(videoFrame,[bbox(1),bbox(2)],label_str(1),'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                videoFrame = insertShape(videoFrame, 'Rectangle',bboxes, 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง

               if ~isplaying(p) && ~strcmp(label_sound(1),'notSign') && ~CheckBoxMute
                     [y,Fs] = audioread(char(label_sound(1)));
                     p=audioplayer(y,Fs); 
                     play(p);
               end


            elseif numBox == 2 && length(label_str) == 2 && ~cellfun(@isempty,label_str(2))%%%%%%% ~cellfun(@isempty,label_str(2) เช็คcell2 ว่าไม่ว่าง
                if strcmp(label_str(1),'notSign') && ~strcmp(label_str(2),'notSign')%label_str(1) notSign แสดง label_str(2)  1 2
                    videoFrame = insertText(videoFrame,[bboxes(2,1),bboxes(2,2)],label_str(2),'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    videoFrame = insertShape(videoFrame, 'Rectangle',[bboxes(2,1),bboxes(2,2),bboxes(2,3),bboxes(2,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง 
                
                elseif strcmp(label_str(2),'notSign') && ~strcmp(label_str(1),'notSign')%label_str(2) notSign แสดง label_str(1)  2 1   
                    videoFrame = insertText(videoFrame,[bboxes(1,1),bboxes(1,2)],label_str(1),'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    videoFrame = insertShape(videoFrame, 'Rectangle',[bboxes(1,1),bboxes(1,2),bboxes(1,3),bboxes(1,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง 

                elseif ~strcmp(label_str(1),'notSign') && ~strcmp(label_str(2),'notSign') %เจอป้ายทั้งคู่ แสดงทั้งสอง  12
                    videoFrame = insertText(videoFrame,[bboxes(1,1),bboxes(1,2);bboxes(2,1),bboxes(2,2)],[label_str(1),label_str(2)],'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    videoFrame = insertShape(videoFrame, 'Rectangle',bboxes, 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง
                    
                end
               if ~isplaying(p) && ~strcmp(label_sound(1),'notSign') && ~CheckBoxMute
                     [y,Fs] = audioread(char(label_sound(1)));
                     p=audioplayer(y,Fs); 
                     play(p);
               end
               
                
            elseif numBox == 3 && length(label_str) == 3 && ~cellfun(@isempty,label_str(2)) && ~cellfun(@isempty,label_str(3))%%%%%%% แก้error label_str ส่งค่าเกิน 1 , ~cellfun(@isempty,label_str(2) เช็คcell2 ว่าไม่ว่าง
                if strcmp(label_str(1),'notSign') && strcmp(label_str(2),'notSign') && ~strcmp(label_str(3),'notSign')% label_str(1)'label_str(2) notsign แสดงlabel_str(3) 12 3
                    videoFrame = insertText(videoFrame,[bboxes(3,1),bboxes(3,2)],label_str(3),'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    videoFrame = insertShape(videoFrame, 'Rectangle',[bboxes(3,1),bboxes(3,2),bboxes(3,3),bboxes(3,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง 
                
                elseif strcmp(label_str(1),'notSign') && strcmp(label_str(3),'notSign') && ~strcmp(label_str(2),'notSign') %13  2   
                    videoFrame = insertText(videoFrame,[bboxes(2,1),bboxes(2,2)],label_str(2),'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    videoFrame = insertShape(videoFrame, 'Rectangle',[bboxes(2,1),bboxes(2,2),bboxes(2,3),bboxes(2,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง 
                
                elseif strcmp(label_str(2),'notSign') && strcmp(label_str(3),'notSign') && ~strcmp(label_str(1),'notSign')  %23  1 
                    videoFrame = insertText(videoFrame,[bboxes(1,1),bboxes(1,2)],label_str(1),'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    videoFrame = insertShape(videoFrame, 'Rectangle',[bboxes(1,1),bboxes(1,2),bboxes(1,3),bboxes(1,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง 

                elseif strcmp(label_str(1),'notSign') && ~strcmp(label_str(2),'notSign') && ~strcmp(label_str(3),'notSign')%1 23
                    videoFrame = insertText(videoFrame,[bboxes(2,1),bboxes(2,2);bboxes(3,1),bboxes(3,2)],[label_str(2),label_str(3)],'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    videoFrame = insertShape(videoFrame, 'Rectangle',[bboxes(2,1),bboxes(2,2),bboxes(2,3),bboxes(2,4);bboxes(3,1),bboxes(3,2),bboxes(3,3),bboxes(3,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง
                    
                elseif strcmp(label_str(2),'notSign') && ~strcmp(label_str(1),'notSign') && ~strcmp(label_str(3),'notSign')%2 13
                    videoFrame = insertText(videoFrame,[bboxes(1,1),bboxes(1,2);bboxes(3,1),bboxes(3,2)],[label_str(1),label_str(3)],'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    videoFrame = insertShape(videoFrame, 'Rectangle',[bboxes(1,1),bboxes(1,2),bboxes(1,3),bboxes(1,4);bboxes(3,1),bboxes(3,2),bboxes(3,3),bboxes(3,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง
                    
                elseif strcmp(label_str(3),'notSign') && ~strcmp(label_str(1),'notSign') && ~strcmp(label_str(2),'notSign')%3 12
                    videoFrame = insertText(videoFrame,[bboxes(1,1),bboxes(1,2);bboxes(2,1),bboxes(2,2)],[label_str(1),label_str(2)],'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    videoFrame = insertShape(videoFrame, 'Rectangle',[bboxes(1,1),bboxes(1,2),bboxes(1,3),bboxes(1,4);bboxes(2,1),bboxes(2,2),bboxes(2,3),bboxes(2,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง
                    
                elseif ~strcmp(label_str(1),'notSign') && ~strcmp(label_str(2),'notSign') && ~strcmp(label_str(3),'notSign')%  123
                    videoFrame = insertText(videoFrame,[bboxes(1,1),bboxes(1,2);bboxes(2,1),bboxes(2,2);bboxes(3,1),bboxes(3,2)],[label_str(1),label_str(2),label_str(3)],'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    videoFrame = insertShape(videoFrame, 'Rectangle',bboxes, 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง  
                end
               if ~isplaying(p) && ~strcmp(label_sound(1),'notSign') && ~CheckBoxMute
                     [y,Fs] = audioread(char(label_sound(1)));
                     p=audioplayer(y,Fs); 
                     play(p);
               end
                
            elseif numBox == 4 && length(label_str) == 4 && ~cellfun(@isempty,label_str(2)) && ~cellfun(@isempty,label_str(3)) && ~cellfun(@isempty,label_str(4))
                if strcmp(label_str(1),'notSign') && strcmp(label_str(2),'notSign') && strcmp(label_str(3),'notSign') && ~strcmp(label_str(4),'notSign')%123 4
                    videoFrame = insertText(videoFrame,[bboxes(4,1),bboxes(4,2)],label_str(4),'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    videoFrame = insertShape(videoFrame, 'Rectangle',[bboxes(4,1),bboxes(4,2),bboxes(4,3),bboxes(4,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง 
                    
                elseif strcmp(label_str(1),'notSign') && strcmp(label_str(2),'notSign') && strcmp(label_str(4),'notSign') && ~strcmp(label_str(3),'notSign')%124 3
                    videoFrame = insertText(videoFrame,[bboxes(3,1),bboxes(3,2)],label_str(3),'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    videoFrame = insertShape(videoFrame, 'Rectangle',[bboxes(3,1),bboxes(3,2),bboxes(3,3),bboxes(3,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง 
                 
                elseif strcmp(label_str(1),'notSign') && strcmp(label_str(3),'notSign') && strcmp(label_str(4),'notSign') && ~strcmp(label_str(2),'notSign')%134 2
                    videoFrame = insertText(videoFrame,[bboxes(2,1),bboxes(2,2)],label_str(2),'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    videoFrame = insertShape(videoFrame, 'Rectangle',[bboxes(2,1),bboxes(2,2),bboxes(2,3),bboxes(2,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง 
                    
                elseif strcmp(label_str(2),'notSign') && strcmp(label_str(3),'notSign') && strcmp(label_str(4),'notSign') && ~strcmp(label_str(1),'notSign')%234 1
                    videoFrame = insertText(videoFrame,[bboxes(1,1),bboxes(1,2)],label_str(1),'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    videoFrame = insertShape(videoFrame, 'Rectangle',[bboxes(1,1),bboxes(1,2),bboxes(1,3),bboxes(1,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง 
                    
                elseif strcmp(label_str(1),'notSign') && strcmp(label_str(2),'notSign') && ~strcmp(label_str(3),'notSign') && ~strcmp(label_str(4),'notSign')%12 34
                    videoFrame = insertText(videoFrame,[bboxes(3,1),bboxes(3,2);bboxes(4,1),bboxes(4,2)],[label_str(3),label_str(4)],'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    videoFrame = insertShape(videoFrame, 'Rectangle',[bboxes(3,1),bboxes(3,2),bboxes(3,3),bboxes(3,4);bboxes(4,1),bboxes(4,2),bboxes(4,3),bboxes(4,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง
                   
                elseif strcmp(label_str(1),'notSign') && strcmp(label_str(3),'notSign') && ~strcmp(label_str(2),'notSign') && ~strcmp(label_str(4),'notSign')%13 24
                    videoFrame = insertText(videoFrame,[bboxes(2,1),bboxes(2,2);bboxes(4,1),bboxes(4,2)],[label_str(2),label_str(4)],'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    videoFrame = insertShape(videoFrame, 'Rectangle',[bboxes(2,1),bboxes(2,2),bboxes(2,3),bboxes(2,4);bboxes(4,1),bboxes(4,2),bboxes(4,3),bboxes(4,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง
               
                elseif strcmp(label_str(1),'notSign') && strcmp(label_str(4),'notSign') && ~strcmp(label_str(2),'notSign') && ~strcmp(label_str(3),'notSign')%14 23
                    videoFrame = insertText(videoFrame,[bboxes(2,1),bboxes(2,2);bboxes(3,1),bboxes(3,2)],[label_str(2),label_str(3)],'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    videoFrame = insertShape(videoFrame, 'Rectangle',[bboxes(2,1),bboxes(2,2),bboxes(2,3),bboxes(2,4);bboxes(3,1),bboxes(3,2),bboxes(3,3),bboxes(3,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง
                
                elseif strcmp(label_str(3),'notSign') && strcmp(label_str(4),'notSign') && ~strcmp(label_str(1),'notSign') && ~strcmp(label_str(2),'notSign')%34 12
                    videoFrame = insertText(videoFrame,[bboxes(1,1),bboxes(1,2);bboxes(2,1),bboxes(2,2)],[label_str(1),label_str(2)],'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    videoFrame = insertShape(videoFrame, 'Rectangle',[bboxes(1,1),bboxes(1,2),bboxes(1,3),bboxes(1,4);bboxes(2,1),bboxes(2,2),bboxes(2,3),bboxes(2,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง
                    
                elseif strcmp(label_str(2),'notSign') && strcmp(label_str(4),'notSign') && ~strcmp(label_str(1),'notSign') && ~strcmp(label_str(3),'notSign')%24 13
                    videoFrame = insertText(videoFrame,[bboxes(1,1),bboxes(1,2);bboxes(3,1),bboxes(3,2)],[label_str(1),label_str(3)],'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    videoFrame = insertShape(videoFrame, 'Rectangle',[bboxes(1,1),bboxes(1,2),bboxes(1,3),bboxes(1,4);bboxes(3,1),bboxes(3,2),bboxes(3,3),bboxes(3,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง
                    
                elseif strcmp(label_str(2),'notSign') && strcmp(label_str(3),'notSign') && ~strcmp(label_str(1),'notSign') && ~strcmp(label_str(4),'notSign')%23 14
                    videoFrame = insertText(videoFrame,[bboxes(1,1),bboxes(1,2);bboxes(4,1),bboxes(4,2)],[label_str(1),label_str(4)],'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    videoFrame = insertShape(videoFrame, 'Rectangle',[bboxes(1,1),bboxes(1,2),bboxes(1,3),bboxes(1,4);bboxes(4,1),bboxes(4,2),bboxes(4,3),bboxes(4,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง
                    
                elseif strcmp(label_str(1),'notSign') && ~strcmp(label_str(2),'notSign') && ~strcmp(label_str(3),'notSign') && ~strcmp(label_str(4),'notSign')%1 234
                    videoFrame = insertText(videoFrame,[bboxes(2,1),bboxes(2,2);bboxes(3,1),bboxes(3,2);bboxes(4,1),bboxes(4,2)],[label_str(2),label_str(3),label_str(4)],'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    videoFrame = insertShape(videoFrame, 'Rectangle',[bboxes(2,1),bboxes(2,2),bboxes(2,3),bboxes(2,4);bboxes(3,1),bboxes(3,2),bboxes(3,3),bboxes(3,4);bboxes(4,1),bboxes(4,2),bboxes(4,3),bboxes(4,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง  
                    
                elseif strcmp(label_str(2),'notSign') && ~strcmp(label_str(1),'notSign') && ~strcmp(label_str(3),'notSign') && ~strcmp(label_str(4),'notSign')%2 134
                    videoFrame = insertText(videoFrame,[bboxes(1,1),bboxes(1,2);bboxes(3,1),bboxes(3,2);bboxes(4,1),bboxes(4,2)],[label_str(1),label_str(3),label_str(4)],'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    videoFrame = insertShape(videoFrame, 'Rectangle',[bboxes(1,1),bboxes(1,2),bboxes(1,3),bboxes(1,4);bboxes(3,1),bboxes(3,2),bboxes(3,3),bboxes(3,4);bboxes(4,1),bboxes(4,2),bboxes(4,3),bboxes(4,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง 
                    
                elseif strcmp(label_str(3),'notSign') && ~strcmp(label_str(1),'notSign') && ~strcmp(label_str(2),'notSign') && ~strcmp(label_str(4),'notSign')%3 124
                    videoFrame = insertText(videoFrame,[bboxes(1,1),bboxes(1,2);bboxes(2,1),bboxes(2,2);bboxes(4,1),bboxes(4,2)],[label_str(1),label_str(2),label_str(4)],'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    videoFrame = insertShape(videoFrame, 'Rectangle',[bboxes(1,1),bboxes(1,2),bboxes(1,3),bboxes(1,4);bboxes(2,1),bboxes(2,2),bboxes(2,3),bboxes(2,4);bboxes(4,1),bboxes(4,2),bboxes(4,3),bboxes(4,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง 
                    
                elseif strcmp(label_str(4),'notSign') && ~strcmp(label_str(1),'notSign') && ~strcmp(label_str(2),'notSign') && ~strcmp(label_str(3),'notSign')%4 123
                    videoFrame = insertText(videoFrame,[bboxes(1,1),bboxes(1,2);bboxes(2,1),bboxes(2,2);bboxes(3,1),bboxes(3,2)],[label_str(1),label_str(2),label_str(3)],'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    videoFrame = insertShape(videoFrame, 'Rectangle',[bboxes(1,1),bboxes(1,2),bboxes(1,3),bboxes(1,4);bboxes(2,1),bboxes(2,2),bboxes(2,3),bboxes(2,4);bboxes(3,1),bboxes(3,2),bboxes(3,3),bboxes(3,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง 
                   
                elseif ~strcmp(label_str(1),'notSign') && ~strcmp(label_str(2),'notSign') && ~strcmp(label_str(3),'notSign') && ~strcmp(label_str(4),'notSign')%  1234
                    videoFrame = insertText(videoFrame,[bboxes(1,1),bboxes(1,2);bboxes(2,1),bboxes(2,2);bboxes(3,1),bboxes(3,2);bboxes(4,1),bboxes(4,2)],[label_str(1),label_str(2),label_str(3),label_str(4)],'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    videoFrame = insertShape(videoFrame, 'Rectangle',bboxes, 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง 
                    
                end
               if ~isplaying(p) && ~strcmp(label_sound(1),'notSign') && ~CheckBoxMute
                     [y,Fs] = audioread(char(label_sound(1)));
                     p=audioplayer(y,Fs); 
                     play(p);
               end
            end



        end 
        %detectedImg = insertObjectAnnotation(videoFrame,'rectangle',bboxes,label_str,'TextBoxOpacity',0.9,'FontSize',18);
        %imshow(detectedImg);
    else
        %imshow(videoFrame);
    end
    imshow(videoFrame);
    drawnow;
    %step(video, videoFrame);
end
release(detector);

function btn_opencam_CreateFcn(hObject, eventdata, handles)
% hObject    handle to btn_opencam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in check_mute.
function check_mute_Callback(hObject, eventdata, handles)
% hObject    handle to check_mute (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_mute


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
