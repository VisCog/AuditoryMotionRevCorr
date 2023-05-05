
p.nt = 10;
p.ns = 10;
        
switch which_model
    
    case 1
        p.modelType = 'box'; % box, diagonal, flat 
        p.boxsize = 1; % used for box model only 
        
    case 2
        
        p.modelType = 'box'; % box, diagonal, flat 
        p.boxsize = 3; % used for box model only 
        
    case 3
        
        p.modelType = 'box'; % box, diagonal, flat 
        p.boxsize = 5; % used for box model only 
        
    case 4
        
        p.modelType = 'diagonal'; % box, diagonal, flat 
        p.diagwidth = 1; % used for diagonal model only
        
    case 5
        
        p.modelType = 'diagonal'; % box, diagonal, flat 
        p.diagwidth = 3; % used for diagonal model only
        
    case 6
        
        p.modelType = 'diagonal'; % box, diagonal, flat 
        p.diagwidth = 5; % used for diagonal model only
        
    case 7
        
        p.modelType = 'flat';
        
    case 8
        
        p.modelType = 'widespace';
        p.timewidth = 2;
        
    case 9
        
        p.modelType = 'narrowspace';
        p.spacewidth = 2;
        
    case 10
        
        p.modelType = 'sep';
        p.scenter = 3;
        p.swidth = 5;
        p.tcenter = 3;
        p.twidth = 1.5;
        
    case 11
        
        p.modelType = 'nonsep';
        p.sigX = 5; % space
        p.sigY = 1.5; % time
        
    case 12
        
        p.modelType = 'sep';
        p.scenter = 3;
        p.swidth = 1.5;
        p.tcenter = 3;
        p.twidth = 5;
        
    case 13
        
        p.modelType = 'nonsep';
        p.sigX = 3; % space
        p.sigY = 1.5; % time
end