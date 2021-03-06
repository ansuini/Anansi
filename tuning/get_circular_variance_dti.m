function c = get_circular_variance_dti(thetas, x)

if size(thetas) ~= size(x)
   x = x'; 
end

exps = exp(1i*thetas);
c = sum(x.*exps);

if sum(x) ~= 0 
    c = c/sum(x);
else
    c = 0; 
end

end