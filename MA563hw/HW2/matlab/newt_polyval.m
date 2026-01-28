function pvals = newt_polyval(nodes, coeffs, xvals)
% NEWT_POLYVAL Evaluate Newton form interpolation polynomial using Horner's method.
%
% Inputs:
%   nodes:  Vector of interpolation nodes [x_0, x_1, ..., x_{n-1}]
%   coeffs: Vector of divided difference coefficients [c_0, c_1, ..., c_{n-1}]
%   xvals:  Vector of query points where the polynomial is evaluated
%
% Output:
%   pvals:  The evaluated values at xvals

    n = length(coeffs);
    pvals = zeros(size(xvals));
    
    % Loop over each query point
    for k = 1:length(xvals)
        x = xvals(k);
        
        % Initialize with the highest order coefficient (c_{n-1})
        val = coeffs(n);
        
        % Apply Horner's Scheme (Nested Multiplication) backwards
        % Loop from n-1 down to 1
        for i = n-1:-1:1
            val = coeffs(i) + (x - nodes(i)) * val;
        end
        
        pvals(k) = val;
    end
end