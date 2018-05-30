function varargout = sign_video(varargin)
% SIGN_VIDEO MATLAB code for sign_video.fig
%      SIGN_VIDEO, by itself, creates a new SIGN_VIDEO or raises the existing
%      singleton*.
%
%      H = SIGN_VIDEO returns the handle to a new SIGN_VIDEO or the handle to
%      the existing singleton*.
%
%      SIGN_VIDEO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SIGN_VIDEO.M with the given input arguments.
%
%      SIGN_VIDEO('Property','Value',...) creates a new SIGN_VIDEO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sign_video_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sign_video_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help sign_video

% Last Modified by GUIDE v2.5 07-May-2018 10:33:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sign_video_OpeningFcn, ...
                   'gui_OutputFcn',  @sign_video_OutputFcn, ...
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


% --- Executes just before sign_video is made visible.
function sign_video_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sign_video (see VARARGIN)


% Choose default command line output for sign_video
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes sign_video wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = sign_video_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in video_start.
function video_start_Callback(hObject, eventdata, handles)
% hObject    handle to video_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global path_video
if ~isempty(path_video)

    detector = vision.CascadeObjectDetector('2000_stage15_0.2.xml');
    load elm_model.mat;
    load gong.mat;% load เสียงของmatlab
    p=audioplayer(y,Fs);
    
    %v = VideoReader('IMG_5533.mov');
    v = VideoReader(path_video);
    axes(handles.axes1);
    while hasFrame(v)
        %%ดึง value จาก popup and checkbox
        dropdown = get(handles.popupmenu1,'String'); 
        speak_language = dropdown{get(handles.popupmenu1,'Value')};
        
        CheckBoxMute=get(handles.check_mute,'Value');

        %%
        video = readFrame(v);
        img=imresize(video,0.5);
        bboxes = step(detector,img);
        image(video, 'Parent', handles.axes1);
        set(handles.axes1, 'Visible', 'off');


        numBox=size(bboxes,1);
    if numBox>0

        label_str=cell(numBox,1);
        label_sound=cell(1);
        
        for boxIndex=1:numBox
            bbox=bboxes(boxIndex,:);
            detectedRegions=imcrop(img,bbox);
   
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
                img = insertText(img,[bbox(1),bbox(2)],label_str(1),'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                img = insertShape(img, 'Rectangle',bboxes, 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง

               if ~isplaying(p) && ~strcmp(label_sound(1),'notSign') && ~CheckBoxMute
                     [y,Fs] = audioread(char(label_sound(1)));
                     p=audioplayer(y,Fs); 
                     play(p);
               end


            elseif numBox == 2 && length(label_str) == 2 && ~cellfun(@isempty,label_str(2))%%%%%%% ~cellfun(@isempty,label_str(2) เช็คcell2 ว่าไม่ว่าง
                if strcmp(label_str(1),'notSign') && ~strcmp(label_str(2),'notSign')%label_str(1) notSign แสดง label_str(2)  1 2
                    img = insertText(img,[bboxes(2,1),bboxes(2,2)],label_str(2),'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    img = insertShape(img, 'Rectangle',[bboxes(2,1),bboxes(2,2),bboxes(2,3),bboxes(2,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง 
                
                elseif strcmp(label_str(2),'notSign') && ~strcmp(label_str(1),'notSign')%label_str(2) notSign แสดง label_str(1)  2 1   
                    img = insertText(img,[bboxes(1,1),bboxes(1,2)],label_str(1),'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    img = insertShape(img, 'Rectangle',[bboxes(1,1),bboxes(1,2),bboxes(1,3),bboxes(1,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง 

                elseif ~strcmp(label_str(1),'notSign') && ~strcmp(label_str(2),'notSign') %เจอป้ายทั้งคู่ แสดงทั้งสอง  12
                    img = insertText(img,[bboxes(1,1),bboxes(1,2);bboxes(2,1),bboxes(2,2)],[label_str(1),label_str(2)],'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    img = insertShape(img, 'Rectangle',bboxes, 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง
                    
                end
               if ~isplaying(p) && ~strcmp(label_sound(1),'notSign') && ~CheckBoxMute
                     [y,Fs] = audioread(char(label_sound(1)));
                     p=audioplayer(y,Fs); 
                     play(p);
               end
               
                
            elseif numBox == 3 && length(label_str) == 3 && ~cellfun(@isempty,label_str(2)) && ~cellfun(@isempty,label_str(3))%%%%%%% แก้error label_str ส่งค่าเกิน 1 , ~cellfun(@isempty,label_str(2) เช็คcell2 ว่าไม่ว่าง
                if strcmp(label_str(1),'notSign') && strcmp(label_str(2),'notSign') && ~strcmp(label_str(3),'notSign')% label_str(1)'label_str(2) notsign แสดงlabel_str(3) 12 3
                    img = insertText(img,[bboxes(3,1),bboxes(3,2)],label_str(3),'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    img = insertShape(img, 'Rectangle',[bboxes(3,1),bboxes(3,2),bboxes(3,3),bboxes(3,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง 
                
                elseif strcmp(label_str(1),'notSign') && strcmp(label_str(3),'notSign') && ~strcmp(label_str(2),'notSign') %13  2   
                    img = insertText(img,[bboxes(2,1),bboxes(2,2)],label_str(2),'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    img = insertShape(img, 'Rectangle',[bboxes(2,1),bboxes(2,2),bboxes(2,3),bboxes(2,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง 
                
                elseif strcmp(label_str(2),'notSign') && strcmp(label_str(3),'notSign') && ~strcmp(label_str(1),'notSign')  %23  1 
                    img = insertText(img,[bboxes(1,1),bboxes(1,2)],label_str(1),'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    img = insertShape(img, 'Rectangle',[bboxes(1,1),bboxes(1,2),bboxes(1,3),bboxes(1,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง 

                elseif strcmp(label_str(1),'notSign') && ~strcmp(label_str(2),'notSign') && ~strcmp(label_str(3),'notSign')%1 23
                    img = insertText(img,[bboxes(2,1),bboxes(2,2);bboxes(3,1),bboxes(3,2)],[label_str(2),label_str(3)],'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    img = insertShape(img, 'Rectangle',[bboxes(2,1),bboxes(2,2),bboxes(2,3),bboxes(2,4);bboxes(3,1),bboxes(3,2),bboxes(3,3),bboxes(3,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง
                    
                elseif strcmp(label_str(2),'notSign') && ~strcmp(label_str(1),'notSign') && ~strcmp(label_str(3),'notSign')%2 13
                    img = insertText(img,[bboxes(1,1),bboxes(1,2);bboxes(3,1),bboxes(3,2)],[label_str(1),label_str(3)],'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    img = insertShape(img, 'Rectangle',[bboxes(1,1),bboxes(1,2),bboxes(1,3),bboxes(1,4);bboxes(3,1),bboxes(3,2),bboxes(3,3),bboxes(3,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง
                    
                elseif strcmp(label_str(3),'notSign') && ~strcmp(label_str(1),'notSign') && ~strcmp(label_str(2),'notSign')%3 12
                    img = insertText(img,[bboxes(1,1),bboxes(1,2);bboxes(2,1),bboxes(2,2)],[label_str(1),label_str(2)],'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    img = insertShape(img, 'Rectangle',[bboxes(1,1),bboxes(1,2),bboxes(1,3),bboxes(1,4);bboxes(2,1),bboxes(2,2),bboxes(2,3),bboxes(2,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง
                    
                elseif ~strcmp(label_str(1),'notSign') && ~strcmp(label_str(2),'notSign') && ~strcmp(label_str(3),'notSign')%  123
                    img = insertText(img,[bboxes(1,1),bboxes(1,2);bboxes(2,1),bboxes(2,2);bboxes(3,1),bboxes(3,2)],[label_str(1),label_str(2),label_str(3)],'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    img = insertShape(img, 'Rectangle',bboxes, 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง  
                end
               if ~isplaying(p) && ~strcmp(label_sound(1),'notSign') && ~CheckBoxMute
                     [y,Fs] = audioread(char(label_sound(1)));
                     p=audioplayer(y,Fs); 
                     play(p);
               end
                
            elseif numBox == 4 && length(label_str) == 4 && ~cellfun(@isempty,label_str(2)) && ~cellfun(@isempty,label_str(3)) && ~cellfun(@isempty,label_str(4))
                if strcmp(label_str(1),'notSign') && strcmp(label_str(2),'notSign') && strcmp(label_str(3),'notSign') && ~strcmp(label_str(4),'notSign')%123 4
                    img = insertText(img,[bboxes(4,1),bboxes(4,2)],label_str(4),'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    img = insertShape(img, 'Rectangle',[bboxes(4,1),bboxes(4,2),bboxes(4,3),bboxes(4,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง 
                    
                elseif strcmp(label_str(1),'notSign') && strcmp(label_str(2),'notSign') && strcmp(label_str(4),'notSign') && ~strcmp(label_str(3),'notSign')%124 3
                    img = insertText(img,[bboxes(3,1),bboxes(3,2)],label_str(3),'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    img = insertShape(img, 'Rectangle',[bboxes(3,1),bboxes(3,2),bboxes(3,3),bboxes(3,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง 
                 
                elseif strcmp(label_str(1),'notSign') && strcmp(label_str(3),'notSign') && strcmp(label_str(4),'notSign') && ~strcmp(label_str(2),'notSign')%134 2
                    img = insertText(img,[bboxes(2,1),bboxes(2,2)],label_str(2),'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    img = insertShape(img, 'Rectangle',[bboxes(2,1),bboxes(2,2),bboxes(2,3),bboxes(2,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง 
                    
                elseif strcmp(label_str(2),'notSign') && strcmp(label_str(3),'notSign') && strcmp(label_str(4),'notSign') && ~strcmp(label_str(1),'notSign')%234 1
                    img = insertText(img,[bboxes(1,1),bboxes(1,2)],label_str(1),'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    img = insertShape(img, 'Rectangle',[bboxes(1,1),bboxes(1,2),bboxes(1,3),bboxes(1,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง 
                    
                elseif strcmp(label_str(1),'notSign') && strcmp(label_str(2),'notSign') && ~strcmp(label_str(3),'notSign') && ~strcmp(label_str(4),'notSign')%12 34
                    img = insertText(img,[bboxes(3,1),bboxes(3,2);bboxes(4,1),bboxes(4,2)],[label_str(3),label_str(4)],'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    img = insertShape(img, 'Rectangle',[bboxes(3,1),bboxes(3,2),bboxes(3,3),bboxes(3,4);bboxes(4,1),bboxes(4,2),bboxes(4,3),bboxes(4,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง
                   
                elseif strcmp(label_str(1),'notSign') && strcmp(label_str(3),'notSign') && ~strcmp(label_str(2),'notSign') && ~strcmp(label_str(4),'notSign')%13 24
                    img = insertText(img,[bboxes(2,1),bboxes(2,2);bboxes(4,1),bboxes(4,2)],[label_str(2),label_str(4)],'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    img = insertShape(img, 'Rectangle',[bboxes(2,1),bboxes(2,2),bboxes(2,3),bboxes(2,4);bboxes(4,1),bboxes(4,2),bboxes(4,3),bboxes(4,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง
               
                elseif strcmp(label_str(1),'notSign') && strcmp(label_str(4),'notSign') && ~strcmp(label_str(2),'notSign') && ~strcmp(label_str(3),'notSign')%14 23
                    img = insertText(img,[bboxes(2,1),bboxes(2,2);bboxes(3,1),bboxes(3,2)],[label_str(2),label_str(3)],'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    img = insertShape(img, 'Rectangle',[bboxes(2,1),bboxes(2,2),bboxes(2,3),bboxes(2,4);bboxes(3,1),bboxes(3,2),bboxes(3,3),bboxes(3,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง
                
                elseif strcmp(label_str(3),'notSign') && strcmp(label_str(4),'notSign') && ~strcmp(label_str(1),'notSign') && ~strcmp(label_str(2),'notSign')%34 12
                    img = insertText(img,[bboxes(1,1),bboxes(1,2);bboxes(2,1),bboxes(2,2)],[label_str(1),label_str(2)],'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    img = insertShape(img, 'Rectangle',[bboxes(1,1),bboxes(1,2),bboxes(1,3),bboxes(1,4);bboxes(2,1),bboxes(2,2),bboxes(2,3),bboxes(2,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง
                    
                elseif strcmp(label_str(2),'notSign') && strcmp(label_str(4),'notSign') && ~strcmp(label_str(1),'notSign') && ~strcmp(label_str(3),'notSign')%24 13
                    img = insertText(img,[bboxes(1,1),bboxes(1,2);bboxes(3,1),bboxes(3,2)],[label_str(1),label_str(3)],'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    img = insertShape(img, 'Rectangle',[bboxes(1,1),bboxes(1,2),bboxes(1,3),bboxes(1,4);bboxes(3,1),bboxes(3,2),bboxes(3,3),bboxes(3,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง
                    
                elseif strcmp(label_str(2),'notSign') && strcmp(label_str(3),'notSign') && ~strcmp(label_str(1),'notSign') && ~strcmp(label_str(4),'notSign')%23 14
                    img = insertText(img,[bboxes(1,1),bboxes(1,2);bboxes(4,1),bboxes(4,2)],[label_str(1),label_str(4)],'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    img = insertShape(img, 'Rectangle',[bboxes(1,1),bboxes(1,2),bboxes(1,3),bboxes(1,4);bboxes(4,1),bboxes(4,2),bboxes(4,3),bboxes(4,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง
                    
                elseif strcmp(label_str(1),'notSign') && ~strcmp(label_str(2),'notSign') && ~strcmp(label_str(3),'notSign') && ~strcmp(label_str(4),'notSign')%1 234
                    img = insertText(img,[bboxes(2,1),bboxes(2,2);bboxes(3,1),bboxes(3,2);bboxes(4,1),bboxes(4,2)],[label_str(2),label_str(3),label_str(4)],'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    img = insertShape(img, 'Rectangle',[bboxes(2,1),bboxes(2,2),bboxes(2,3),bboxes(2,4);bboxes(3,1),bboxes(3,2),bboxes(3,3),bboxes(3,4);bboxes(4,1),bboxes(4,2),bboxes(4,3),bboxes(4,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง  
                    
                elseif strcmp(label_str(2),'notSign') && ~strcmp(label_str(1),'notSign') && ~strcmp(label_str(3),'notSign') && ~strcmp(label_str(4),'notSign')%2 134
                    img = insertText(img,[bboxes(1,1),bboxes(1,2);bboxes(3,1),bboxes(3,2);bboxes(4,1),bboxes(4,2)],[label_str(1),label_str(3),label_str(4)],'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    img = insertShape(img, 'Rectangle',[bboxes(1,1),bboxes(1,2),bboxes(1,3),bboxes(1,4);bboxes(3,1),bboxes(3,2),bboxes(3,3),bboxes(3,4);bboxes(4,1),bboxes(4,2),bboxes(4,3),bboxes(4,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง 
                    
                elseif strcmp(label_str(3),'notSign') && ~strcmp(label_str(1),'notSign') && ~strcmp(label_str(2),'notSign') && ~strcmp(label_str(4),'notSign')%3 124
                    img = insertText(img,[bboxes(1,1),bboxes(1,2);bboxes(2,1),bboxes(2,2);bboxes(4,1),bboxes(4,2)],[label_str(1),label_str(2),label_str(4)],'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    img = insertShape(img, 'Rectangle',[bboxes(1,1),bboxes(1,2),bboxes(1,3),bboxes(1,4);bboxes(2,1),bboxes(2,2),bboxes(2,3),bboxes(2,4);bboxes(4,1),bboxes(4,2),bboxes(4,3),bboxes(4,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง 
                    
                elseif strcmp(label_str(4),'notSign') && ~strcmp(label_str(1),'notSign') && ~strcmp(label_str(2),'notSign') && ~strcmp(label_str(3),'notSign')%4 123
                    img = insertText(img,[bboxes(1,1),bboxes(1,2);bboxes(2,1),bboxes(2,2);bboxes(3,1),bboxes(3,2)],[label_str(1),label_str(2),label_str(3)],'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    img = insertShape(img, 'Rectangle',[bboxes(1,1),bboxes(1,2),bboxes(1,3),bboxes(1,4);bboxes(2,1),bboxes(2,2),bboxes(2,3),bboxes(2,4);bboxes(3,1),bboxes(3,2),bboxes(3,3),bboxes(3,4)], 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง 
                   
                elseif ~strcmp(label_str(1),'notSign') && ~strcmp(label_str(2),'notSign') && ~strcmp(label_str(3),'notSign') && ~strcmp(label_str(4),'notSign')%  1234
                    img = insertText(img,[bboxes(1,1),bboxes(1,2);bboxes(2,1),bboxes(2,2);bboxes(3,1),bboxes(3,2);bboxes(4,1),bboxes(4,2)],[label_str(1),label_str(2),label_str(3),label_str(4)],'AnchorPoint','LeftBottom');%bbox(1),bbox(2) ใช้แค่ x1,y1 ระบุตำแหน่ง
                    img = insertShape(img, 'Rectangle',bboxes, 'LineWidth', 3);% ใช้ x,y,w,h ระบุตำแหน่ง 
                    
                end
               if ~isplaying(p) && ~strcmp(label_sound(1),'notSign') && ~CheckBoxMute
                     [y,Fs] = audioread(char(label_sound(1)));
                     p=audioplayer(y,Fs); 
                     play(p);
               end
            end



        end 
        %detectedImg = insertObjectAnnotation(img,'rectangle',bboxes,label_str,'TextBoxOpacity',0.9,'FontSize',18);
        %imshow(detectedImg);
    else
        %imshow(img);
    end
        imshow(img);
        drawnow;
        %step(video, img);
        
    end

else
    msgbox(sprintf('Error'),'Error','Error');
end




function file_location_Callback(hObject, eventdata, handles)
% hObject    handle to file_location (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of file_location as text
%        str2double(get(hObject,'String')) returns contents of file_location as a double


% --- Executes during object creation, after setting all properties.
function file_location_CreateFcn(hObject, eventdata, handles)
% hObject    handle to file_location (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_browse.
function btn_browse_Callback(hObject, eventdata, handles)
% hObject    handle to btn_browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global path_video %ประกาศตัวแปร
[chosenfile, chosenpath]=uigetfile('*', 'Select a video');
if ~ischar(chosenfile)
   msgbox(sprintf('Error'),'Error','Error');
   return;   %user canceled dialog
end
path_video = fullfile(chosenpath, chosenfile);

set(handles.file_location,'string',path_video);



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


% --- Executes on button press in check_mute.
function check_mute_Callback(hObject, eventdata, handles)
% hObject    handle to check_mute (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_mute
