function R = cost(V)
    globals;
    R = 0.5*V(1:(N+1)*(Q+1)).^2./V((N+1)*(Q+1)+1:end);
    R = sum(R);
end

