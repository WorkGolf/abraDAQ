function varargout=GetDoubleFromFile(varargin)
%% GetDoubleFromFile  Get data that are apassed by the PassDoubleThruFile
% The function is called 1:st time for initiation and then repatedly to get
% data. It can also be called to get info about how many data blocks that 
% put on the file and the clock info from the passing procedure
% Initiation
% ==========
%Inputs: Proc    - Procedure number
%Output:
%        MMF     - The MEMMAPFILE object associated to Proc
%        Iret    - Return code. If = 0 then everything is alright
% Obtaining data block info and clock
% ===================================
%Inputs: MMF      - The MEMMAPFILE object
%Output:
%        NBlocks  - Number of available blocks
%        CLOCK    - The clock setting associated with the mapped file 
%        Size     - Data size info (No of blocks, rows, cols, layers)
%        Iret     - Return code. If = 0 then everything is alright
% Obtaining data
% ==============
%Inputs: MMF      - The MEMMAPFILE object
%        BlockInd - The indices for the blocks to be read
%Output:
%        DataBlock - The data block read
%        Iret      - Return code. If = 0 then everything is alright



%Written: 2015-06-19, Thomas Abrahamsson, Chalmers University of Technology

Proc=varargin{1};

if strcmpi(class(Proc),'double') && nargin==1;% Initiate data transfer file
  try
    FileName=[tempdir 'DataContainer' int2str(Proc) '.mat'];
    varargout{1}=memmapfile(FileName, 'Writable', false, 'Format', 'double');
    varargout{2}=0;    
  catch
    lasterr
    varargout{1}=[];
    varargout{2}=-1;
    return
  end  
elseif strcmpi(class(Proc),'memmapfile') && nargin==1;% Get NblocksAvailable
                                                      % and other data
  try
    MMF=varargin{1};
    varargout{1}=MMF.Data(end);%           NblocksAvailable
    varargout{2}=MMF.Data(end-[10:-1:5])';% Clock
    varargout{3}=MMF.Data(end-[4:-1:1]);%  Size
    varargout{4}=0;%                       Iret
  catch
    lasterr
    varargout{1}=[];
    varargout{2}=[];
    varargout{3}=[];
    varargout{4}=-2;
  end 
elseif strcmpi(class(Proc),'memmapfile') && nargin==2;% Get data
  try
    MMF=varargin{1};
    BlockInd=varargin{2};
    Nrows=MMF.Data(end-3);
    Ncols=MMF.Data(end-2);
    Nlays=MMF.Data(end-1);
    NdataInBlock=Nrows*Ncols*Nlays;
    Nblocks=length(BlockInd);
    ind=[];
    for I=1:Nblocks
      ind=[ind (BlockInd(I)-1)*NdataInBlock+[1:NdataInBlock]];
    end
    Data=MMF.Data(ind);
    varargout{1}=squeeze(reshape(Data,Nrows,Ncols,Nlays,Nblocks));
    varargout{2}=0;
  catch
    lasterr
    varargout{1}=[];
    varargout{2}=-1;
  end  
else
  error(' ');
end
