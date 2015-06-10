function D=GetDataFromFile(FileNo,Name,opt)
%% GetDataFromFile
%Inputs: FileNo - Number of process
%        Name   - Data name
%        opt    - opt.keep=true keeps the data on file after reading
%                 default is opt.keep=false
%Output: D      - The data read

%Written: 2015-06-02, Thomas Abrahamsson, Chalmers University of Technology

if nargin<3,opt.keep=false;end

try 
  m=matfile([tempdir 'DataContainer' int2str(FileNo)],'Writable',true);
catch
  disp('DataContainer file cannot by found in tempdir')
  D=[];
  return
end

try
  eval(['D=m.' Name ';']);
  if ~opt.keep
    eval(['m.' Name '=[];']);
  end  
catch
%   lasterr
%   disp(['Specified data "' Name '" cannot be found in DataContainer'])
  D=[];
  return
end

  
  
