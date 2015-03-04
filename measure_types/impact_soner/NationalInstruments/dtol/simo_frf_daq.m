function [f,Y,stdY]=simo_frf_daq(ao,ai,Freqs,Loads,Convp)
%SIMO_FRF_DAQ: 
% Inputs: ao        - Analog output object
%         ai        - Analog input object
%         Freqs     - Frequencies of excitation
%         Loads     - Amplitudes of excitation
%         Convp     - Convergence parameters
% Output: Y         - Output matrix of complex amplitudes. Size ny x na
%                     (na, ny - number of averages and number of outputs)
%         stdY      - Standard deviation of estimate of Y
% Call:   [f,Y,stdY]=simo_frf_daq(ao,ai,Freqs,Loads,Convp)


%%                                                                  Globals
global CH

%%                                                        Initiate and test
%Nch=length(ai.Channel);
Ncycles=10;                                 % Number of periods to collect
Fs=ai.SampleRate; Ts=1/Fs;
RHlim=Convp{1};RSlim=Convp{2};RNlim=Convp{3};Itermax=Convp{4};
f=Freqs;
Userdata=get(ai,'User');
cal=Userdata.cal;

%%                                                             Initiate GUI
frf_gui;

for I=1:length(Freqs)
  freq=Freqs(I);
  try,load=Loads(I);catch, load=Loads;end
%%                                      Create load signal and start output
  N=Fs/freq; t=0:Ts:N*Ts;
  u=load*sin(2*pi*freq*t(1:(end-1))); % Create one period of sinusoidal
  ws=warning;warning('off');
  set(ao,'RepeatOutput',Inf);       % Repeat it forever (until buffer full)
  warning(ws);

%%                                         Put data and start Analog Output
%                                          The try/catch is a fix for 
%                                          buffering problems that occurred
%                                          (put 2 cycles instead of one)
  putdata(ao,u(:));
  try
  start(ao);                               
  catch
    putdata(ao,[u(:);u(:)]);
    start(ao);
  end

%%                                            Set blocksize of Analog Input
  blocksize=Ncycles*length(t);              % Allow Ncycles cycles in block
  set(ai,'SamplesPerTrigger',blocksize);

  Iter=1;
  RHmax=inf;RNmax=inf;RSmax=inf;

%%                                      Repeat until criteria are fulfilled
  while Iter<=Itermax & RSmax>RSlim & RNmax>RNlim & RHmax>RHlim
    Iter=Iter+1;
%%                                                             Collect data
    start(ai);
    while isrunning(ai), pause(0.001);end
    [y,t] = getdata(ai);
  
    %if Iter==2,figure,plot(t,y(:,1)),pause,end
    
    %close all,plot(t,y(:,1))
  
%%                                               Obtain harmonic properties
%         c  - complex amplitudes of harmonics
%         RN - Residual noise (normalized with respect to signal)
%         RH - Harmonic distorsion (normalized with respect to signal)
%         RS - Stationarity deviation
%         C  - Cycle-per-cycle amplitude of 0:th order harmonics 
    order=2;
    [c,RN(:,I),RH(:,I),RS(:,I),C]=harmonics(y,Ts,freq,order);
    
%%                        Get channel max (noise, distorsion, stationarity)
    RNmax=max(RN(CH.eval,I));
    RHmax=max(RH(CH.eval,I));
    RSmax=max(RS(CH.eval,I));
    
  end
  
 
%%                                               Establish (calibrated) FRF  
  Yc=diag(cal)*C./repmat(cal(CH.refch)*C(CH.refch,:),size(C,1),1);
  Y(:,I)=mean(Yc,2);
  stdY(:,I)=std(Yc,0,2);
  
  frf_gui(t,y*diag(cal),Freqs,Y,stdY,RN,RH,RS);
  
%%                                                       Stop Analog Output
  stop(ao);
  pause(0.2);% This pause makes transition to next frequency smoother

end