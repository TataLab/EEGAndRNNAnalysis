function save_plot(hndl,name)
% INPUTS:   - hndl: handle of figure
%           - name: string of name(may include directory)
% saveas(hndl,name,'pdf');
% saveas(hndl,name,'tif');
% savefig(name)
set(hndl, 'PaperPositionMode', 'Auto');
eval(sprintf('print -painters -dpdf -r600 ''%s''',name));
return