function PassDataThruFile(FileNo,Name,D,opt)
%% PassDataThruFile
%Inputs: FileNo - Number of process
%        Name   - Data name
%        D      - The data to be passed
%        opt    - opt.refresh=true starts with an empty data transfer file
%                 opt.refresh=false is default
%Output: none

%Written: 2015-06-02, Thomas Abrahamsson, Chalmers University of Technology

if nargin<4,opt.refresh=false;end

eval([Name '=D;']);
if opt.refresh
    save([tempdir 'DataContainer' int2str(FileNo)],Name);  
else
  try 
    save([tempdir 'DataContainer' int2str(FileNo)],Name,'-append');
  catch
    save([tempdir 'DataContainer' int2str(FileNo)],Name);
  end
end  