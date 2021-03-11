function [condition,conditionarray] = getCond(DE,NDE,PS,NS)


condition= table(...
[DE NDE DE NDE DE DE DE DE DE DE NDE NDE DE DE NDE NDE DE DE NDE NDE DE DE NDE NDE ]',... %the eye is identified by the suppressor
[PS NS  NS PS  PS NS PS NS PS PS NS  NS  NS NS PS  PS  NS PS PS  NS  PS NS NS  PS]',... %the tilt must be identified by the adapter or the suppressor
[1  1   1  1   1  1  0  0  1  1  1   1   1  1  1   1   0  0  0   0   0  0  0   0]',... %tiltmatch
[0  0   0  0   0  0  0  0  1  0  1   0   1  0  1   0   1  0  1   0   1  0  1   0]',... %adaptor
[0  0   0  0   0  0  0  0  0  1  0   1   0  1  0   1   0  1  0   1   0  1  0   1]',... %suppressor
[0  0   0  0   0  0  0  0  0  800 0  800 0  800 0  800 0  800 0  800 0  800 0  800]',... %soa
[1  1   1  1   0  0  0  0  1  0  1   0   1  0  1   0   1  0  1   0   1  0  1   0]',... %monoc
'VariableNames',{'eyes1','tilt1','tiltmatch','adaptor','suppressor','soa','monoc'});

condition.Properties.RowNames = {...
    'Monocualr PS DE',...
    'Monocualr NS NDE',...
    'Monocualr NS DE',...
    'Monocualr PS NDE',...
    'Cong PS Simult',...
    'Cong NS Simult',...
    'IC PS DE - NS NDE Simult',...
    'IC NS DE - PS NDE Simult',...
    'C PS NDE adapting - PS DE to be flashed',... 1
    'C PS DE flash - PS NDE adapted',... 1
    'C NS DE adapting - NS NDE to be flashed',... 2
    'C NS NDE flash - NS DE adapted',... 2
    'C NS NDE  adapting - NS DE to be flashed',... 3
    'C NS DE flash - NS NDE adapted',... 3
    'C PS DE adapting - PS NDE to be flashed',... 4
    'C PS NDE flash - PS DE adapted',... 4
    'IC NS NDE adapting - PS DE to be flashed',... 5
    'IC PS DE flash - NS NDE adapted',... 5
    'IC PS DE adapting - NS NDE to be flashed',... 6
    'IC NS NDE flash - PS DE adapted',... 6
    'IC PS NDE adapting - NS DE to be flashed',... 7
    'IC NS DE flash - PS NDE adapted',... 7
    'IC NS DE adapting - PS NDE to be flashed',... 
    'IC PS NDE flash - NS DE adapted',... 8
    };


conditionarray = table2array(condition);

