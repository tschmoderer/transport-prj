function pJ = proxJ(V)
    globals;
    mt = reshape(V(1:(N+1)*(Q+1)),Q+1,N+1);
    ft = reshape(V((N+1)*(Q+1)+1:end),Q+1,N+1);
    
    Poly = @(x)(-0.5*gamma*mt.^2+(x-ft).*((x+gamma).^2));
	dP = @(x)(2*(x+gamma).*(x-ft)+(x+gamma).^2);
 
	x0 = 1000;
	x1 = 0;
	k = 0;

	% Newton
	while norm(x0-x1,1) > 1e-5 && k < 1500
		x0 = x1;
        poly = (x0-ft).*((x0+g).^2)-0.5*g*mt.^2;
        dpoly = 2*(x0+g).*(x0-ft)+(x0+g).^2;
        ddpoly = 2*(3*x0+2*g-ft);
        x1 = x0 - 2*poly.*dpoly./(2*dpoly.^2 - poly.*ddpoly);
        %   x1 = x0 - poly./dpoly;
        %	x1 = x0 - Poly(x0)./dP(x0);
        k = k+1;
    end
   
	Pf = x1;
	Pm = Pf.*mt./(Pf + g);
    
 	idx = find(Pf <= 0);
 	Pm(idx) = 0;
 	Pf(idx) = 0;

    pJ = [reshape(Pm,(N+1)*(Q+1),1);reshape(Pf,(N+1)*(Q+1),1)];
end


