function interpolatedcube(x, y, vals)

    if nargin == 2 % responseobject has been passed
        ind = y;
        y = x.positions(:,2);
        vals = x.responses(:,ind);
        x = x.positions(:,1);
    end

    interpolant = scatteredInterpolant(x, y, vals);
    [xx,yy] = meshgrid(linspace(min(x), max(x),100),...
                        linspace(min(y), max(y),100));
    value_interp = interpolant(xx,yy); 
    % value_interp = max(value_interp, 0); % Don't allow extrapolation below zero
    
    % Remove points from outside net
    for k = 1:size(xx,1)
        for j = 1:size(xx,2)
            if (yy(k,j) > 30 || yy(k,j) < 0) && (xx(k,j) > 60 || xx(k,j) < 30)
                value_interp(k,j) = nan;
            end
        end
    end
    contourf(xx,yy,value_interp, 100, 'LineStyle', 'none');
    colorbar;
    axis off;
    set(gcf, 'color', 'w');

end