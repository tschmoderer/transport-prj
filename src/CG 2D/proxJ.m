% Validée
% generealised cost 

function Pw = proxJ(w,g,b)
    mt = w(:,:,:,1:2);
    ft = w(:,:,:,3);
    
    x0 = 1;
    x1 = 2;
    k = 0;
    
    % Newton
    while norm(x0(:)-x1(:),1) > 1e-5 && k < 100
        x0 = x1;
        if b == 1 % cas transport
            poly = (x0-ft).*((x0+g).^2)-0.5*g*(mt(:,:,:,1).^2 + mt(:,:,:,2).^2);
            dpoly = 2*(x0+g).*(x0-ft)+(x0+g).^2;
        elseif b == 0 % cas interpolation 
            x1 = ft;
            break
        else
            poly = x0.^(1-b).*(x0-ft).*((x0.^b+g).^2)-0.5*b*g*(mt(:,:,:,1).^2 + mt(:,:,:,2).^2);
            dpoly = (1-b)*x0.^(-b).*(x0-ft).*((x0.^b+g).^2) + x0.^(1-b).*((x0.^b+g).^2 +2*b*(x0-ft).*x0.^(b-1).* (x0.^b+g) );
        end
        x1 = x0 - poly./dpoly;
        k = k+1;
    end

    Pf = x1;
    Pm = (Pf.^b).*mt./(Pf.^b + g);

    idx = find(Pf < 0); % ou la racine est négative
    Pm(idx) = 0;
    Pf(idx) = 0;
    
    Pw = zeros(size(w));
    Pw(:,:,:,1:2) = real(Pm);
    Pw(:,:,:,3) = real(Pf);
end


