% --- Executes on button press in startButton.
function startButton_Callback(hObject, eventdata, handles)
% hObject    handle to startButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Author: Mladen Gibanica(*)(**) and Thomas Abrahamsson(*)
% (*) Chalmers University of Technology
% Email address: mladen.gibanica@chalmers.se, thomas.abrahamsson@chalmers.se  
% Website: https://github.com/mgcth/abraDAQ
% May 2015; Last revision: 21-May-2015

% Check which test
if get(handles.monitor,'Value') == 1 % if monitor
    TestType='monitor';
    dataOut = startMonitor(hObject, eventdata, handles);
    
elseif get(handles.dataLogg,'Value') == 1 % if standard test
    TestType='logging';
    dataOut = startLogg(hObject, eventdata, handles);
    
elseif get(handles.impactTest,'Value') == 1 % if impactTest
    TestType='impact';
    dataOut = startImpact(hObject, eventdata, handles);
    
elseif get(handles.periodic,'Value') == 1 % if periodic
    TestType='periodic';
    dataOut = startPeriodic(hObject, eventdata, handles);
    
elseif get(handles.steppedSine,'Value') == 1 % if steppedSine
    TestType='steppedsine';
    dataOut = startMultisine(hObject, eventdata, handles);
    
elseif handles.multisine.Value == 1 % if multisine
    TestType='multisine';
    dataOut = startMultisine(hObject, eventdata, handles);
    
end

TS=[];FRD=[];
if iscell(dataOut)
  for I=1:length(dataOut)
    if strcmpi(class(dataOut{I}),'timeseries')
      TS=dataOut{I};
    elseif strcmpi(class(dataOut{I}),'frd') || strcmpi(class(dataOut{I}),'idfrd')
      FRD=dataOut{I};
    end    
  end  
else
  if strcmpi(class(dataOut),'timeseries')
    TS=dataOut;
  elseif strcmpi(class(dataOut),'frd') || strcmpi(class(dataOut),'idfrd')
    FRD=dataOut;
  end    
end

if strcmpi(TestType,'impact') || strcmpi(TestType,'periodic') || ...
    strcmpi(TestType,'steppedsine') || strcmpi(TestType,'multisine') || ...
     strcmpi(TestType,'logging')
  abraDAQterm(TS,FRD);
end

% Check if report is to be generated
if get(handles.autoReport,'Value') && ~get(handles.monitor,'Value')
    try
        %dataIn = dataOut.Data;
        %dataIn.UserData = dataOut.Metadata;
        dataIn = dataOut;
        viblab_report(dataIn,handles)
    catch
        %errordlg('Something wrong with the report generation.')
    end
end

% Check if write to UFF
if get(handles.write2UFF,'Value')
    name = handles.title1;
    
    if isempty(get(handles.title1,'String'))
        name = ['dummy_', num2str(randi([1 1000],1,1))];
    end
    
    if isa(dataIn,'idfrd')
        frd2uff(name, dataIn);
    else
        ts2uff(name, dataIn);
    end
end