function [condition,conditionarray] = getAdaptorCond(DE,NDE,PS,NS)


condition= table(...
[NDE DE  ]',... %the eye is identified by the suppressor
[PS  PS ]',... %the tilt must be identified by the adapter or the suppressor
[1  1     ]',... %tiltmatch
[1  1  ]',... %adaptor
[0  0   ]',... %suppressor
[800 800    ]',... %soa
[1  1    ]',... %monoc
'VariableNames',{'eyes1','tilt1','tiltmatch','adaptor','suppressor','soa','monoc'});

condition.Properties.RowNames = {...
    'Monoc adaptor PS DE',...
    'Monoc adaptor PS NDE' };


conditionarray = table2array(condition);

