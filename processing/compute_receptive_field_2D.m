function f = compute_receptive_field_2D(pars, i, SHOW)


f = struct();

[blockname, name] = get_blockname_and_filename_from_index(pars, i);
parts = strsplit(name, '.');
ind = str2num(parts{1});
filename = fullfile(pars.paths.rfquality, blockname, 'fitresulto.mat');
R = load(filename);
RF = R.RFo{1,ind};

x = 1:1:11;
y = 1:1:6;
dim = 6*11;
[X,Y] = meshgrid(x,y);


epsilon = 0;
[sx,sy,sz]=size(RF);

if sz == 3
    RF = rgb2gray(RF);
end

[X,Y] = meshgrid(1:sy,1:sx);

RFcut = zeros(size(RF));
RFcut(find((RF > epsilon*max(RF(:))))) = RF(find(( RF > epsilon*max(RF(:)))))
[xData, yData, zData] = prepareSurfaceData(X, Y, RFcut);

[maximum, loc] = max(RF(:));
[my, mx] = ind2sub(size(RF),loc);


% Set up fittype and options.

ft = fittype( 'a*exp(  - (1/(2*(1 - rho^2)))*( ((x - x0)./sigmax ).^2  + ((y - y0)./sigmay ).^2  - 2*rho*(  ((x - x0)*(y - y0))/(sigmax*sigmay)    )  )) + b', 'independent', {'x', 'y'}, 'dependent', 'z', 'coefficients', {'b', 'a', 'rho', 'x0', 'y0', 'sigmax','sigmay'} );
fop = fitoptions(ft); 0
fop.StartPoint = [min(RFcut(:)) max(RFcut(:)) 0 mx my 5 5];
fop.Lower = zeros(1,6);
fop.Upper = inf*ones(1,6);   

% Fit model to data
try
    
    [fitresult, gof, fout] = fit( [xData, yData], zData, ft, fop);
    a = fitresult.a;
    rho = fitresult.rho;
    b = fitresult.b;
    sigmax = fitresult.sigmax;
    sigmay = fitresult.sigmay;
    x0 = fitresult.x0;
    y0 = fitresult.y0;

    
    %nsx = 1 : 0.1: 6;
    %nsy = 1 : 0.1: 11;
    
    nsx = linspace(0.5, 6.5, 61);
    nsy = linspace(0.5, 11.5, 111);
    [NX,NY] = meshgrid(nsy ,nsx);

    zfit = a*exp(  - (1/(2*(1 - rho^2)))*( ((NX - x0)./sigmax ).^2  + ((NY - y0)./sigmay ).^2  - 2*rho*(  ((NX - x0).*(NY - y0))/(sigmax*sigmay)    )  )) + b;

    % normalize
    
    zfit = zfit/max(zfit(:));
    zfit = zfit*max(RF(:));
    
    f.success = 1;
    f.fitresult = fitresult;
    f.gof = gof;
    f.fout = fout;
    f.zfit = zfit;    
    f.RF = RF;
   
catch err
    
   err.identifier
    
   % Give more information for mismatch.
   if (strcmp(err.identifier,'curvefit:fit:infComputed'))

      msg = ['RF not fitted !'];

   % Display any other errors as usual.
   else
      rethrow(err);
   end
   
   f.success = 0;
   f.RF = RF;
  

end  % end try/catch

%%
resizedRF = zeros(numel(nsx), numel(nsy));
for i = 1:6
    for j = 1:11
        pivot = RF(i,j);
        resizedRF((i-1)*10 + 1:i*10, (j-1)*10 + 1: j*10) = repmat(pivot, 10, 10);
    end
end
%%


if SHOW
    figure
    subplot(2,2,1)
    hold on
    imagesc(resizedRF)
    contour(f.zfit)
    colormap(bone)
    plot(f.fitresult.x0*10, f.fitresult.y0*10, '.r', 'MarkerSize', 10 )
    set(gca, 'XLim', [1, numel(nsy)])
    set(gca, 'YLim', [1, numel(nsx)])
    set(gca, 'YDir', 'normal' )
    colorbar
    
    subplot(2,2,2)
    hold on
    imagesc(f.zfit)
    contour(f.zfit)
    set(gca, 'XLim', [1, numel(nsy)])
    set(gca, 'YLim', [1, numel(nsx)])
    set(gca, 'YDir', 'normal' )    
    
    colormap(bone)
    title(['rsq = ', num2str(f.gof.rsquare), 'correlation = ', num2str(f.fitresult.rho) ])
    colorbar
    
    subplot(2,2,3)
    surf(RF)
    
    subplot(2,2,4)
    surf(f.zfit)
    
    
    
    
end



end
 
