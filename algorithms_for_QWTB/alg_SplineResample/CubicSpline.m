% spline = CubicSpline(t, record) - t,record are vectors of same length
% y_new = spline.evaluate(t2) - t2 is vector with new timing positions
% 
classdef CubicSpline
    % CubicSpline - Class for cubic splines interpolation.

    properties
        x
        y
        n
        a
        b
        c
        d
    end

    methods
        function obj = CubicSpline(t, record)
            % Constructor for CubicSpline class.
            % Check inputs
            if numel(t) < 1
                error('CubicSpline: empty time vector, cannot calculate splines on empty data!')
            end
            if numel(t) ~= numel(record)
                error('CubicSpline: length of input time vector differs from input record vector!')
            end
            % Set object:
            obj.x = t;
            obj.y = record;
            obj.n = length(t);
            [obj.a, obj.b, obj.c, obj.d] = obj.calculateCoefficients();
        end % function CubicSpline

        function [a, b, c, d] = calculateCoefficients(obj)
            % Calculate spline coefficients.
            a = obj.y;
            b = zeros(1, obj.n);
            c = zeros(1, obj.n);
            d = zeros(1, obj.n);
            h = diff(obj.x);
            alpha = zeros(1, obj.n - 2);

            %% Part 1
            % Code represented as a loop (slow way): 
                % for i = 2:(obj.n - 1)
                    % alpha(i-1) = (3 / h(i-1)) * (a(i + 1) - a(i)) - (3 / h(i-1)) * (a(i) - a(i - 1));
                % end
            % The same code, but faster, without for loop:
            a_ip1 = [ a  NaN NaN];
            a_i =   [NaN  a  NaN];
            a_im1 = [NaN NaN  a ];
            h_im1 = [NaN  h  NaN NaN]; % NaN two times because h is result of diff, that is shorter by 1 element
            alpha = (3 ./ h_im1) .* (a_ip1 - a_i) - (3 ./ h_im1) .* (a_i - a_im1);
            % remove excess NaNs:
            % If x or y is empty, next line will fail:
            alpha = alpha(3 : end-2);

            %% Part 2
            l = ones(1, obj.n);
            mu = zeros(1, obj.n);
            z = zeros(1, obj.n);
            % Original slower code:
                % for i = 2:(obj.n - 1)
                %     l(i) = 2 * (obj.x(i + 1) - obj.x(i - 1)) - h(i - 1) * mu(i - 1);
                %     mu(i) = h(i) / l(i);
                %     z(i) = (alpha(i - 1) - h(i - 1) * z(i - 1)) / l(i);
                % end
            % The same code, but calculation of mu was taken out from the loop
            % to save about 2-7 % of calculation time:
            for i = 2:(obj.n - 1)
                l(i) = 2 * (obj.x(i + 1) - obj.x(i - 1)) - h(i - 1).*h(i - 1)./l(i - 1);
                z(i) = (alpha(i - 1) - h(i - 1) * z(i - 1)) / l(i);
            end
            mu = [h 0]./l;
            mu(1) = 0;

            %% Part 3
            % Original slower code:
                % for j = (obj.n - 1):-1:1
                %     c(j) = z(j) - mu(j) * c(j + 1);
                %     b(j) = (a(j + 1) - a(j)) / h(j) - h(j) * (c(j + 1) + 2 * c(j)) / 3;
                %     d(j) = (c(j + 1) - c(j)) / (3 * h(j));
                % end
            % The same code, but calculation of b and d was taken out from the
            % loop to save about 50 % of calculation time
            for j = (obj.n - 1):-1:1
                c(j) = z(j) - mu(j) * c(j + 1);
            end
            h_j = [0 h 0 0];
            c_jp1 = [c 0 0];
            c_j = [0 c 0];
            a_jp1 = [a 0 0];
            a_j = [0 a 0];
            b = (a_jp1 - a_j)./h_j - h_j.*(c_jp1 + 2.*c_j)./3;
            d = (c_jp1 - c_j)./(3 .* h_j);
            b = b(2:end-1);
            d = d(2:end-1);
            b(end) = 0; % because b was initialized as b = zeros..
            d(end) = 0; % because d was initialized as d = zeros..

        end % function calculateCoefficients

        function y_eval = evaluate(obj, x_eval, varargin)
            % Evaluate the spline at given points.
            %
            % Parameters
            % ----------
            % x_eval: Array of double
            %     X coordinates of evaluated points
            %     fast_method: selects a method for calculation. If 1, faster method is selected. Default is 0.
            %
            % Returns
            % -------
            % y_eval: Array of double
            %     Y coordinates of evaluated splines.

            % Check inputs
            if isempty(x_eval)
                error('Empty new time vector. Cannot evaluate spline on empty data!')
            end
            if nargin < 3
                % Use arrayfun method as a failsafe.
                fast_method = 0;
            else
                fast_method = varargin{1};
                % ensure method is boolean:
                fast_method = not(not(fast_method));
            end

            % Evaluate spline:
            if fast_method
                % Slower method. Using arrayfun. Much faster than simple for cycles, 3x slower
                % than faster method, but less memory demanding.
            
                x_eval = reshape(x_eval, [], 1); % Ensure x_eval is a column vector
                y_eval = zeros(size(x_eval)); % Initialize y_eval with the same size as x_eval

                indices = arrayfun(@(x) find(obj.x <= x, 1, 'last'), x_eval);
                indices(indices < 1) = 1;
                indices(indices > numel(obj.x) - 1) = numel(obj.x) - 1;

                % Compute the spline polynomial for each segment
                for i = 1:length(x_eval)
                    dx = x_eval(i) - obj.x(indices(i))';
                    y_eval(i) = obj.a(indices(i)) + obj.b(indices(i)) * dx + ...
                                obj.c(indices(i)) * dx^2 + obj.d(indices(i)) * dx^3;
                end
            else
                % Faster method. Using bsxfun.
                indexes = reshape(sum(bsxfun(@le, obj.x(:), x_eval(:).'), 1), size(x_eval)); 
                % Now size(indexes) is same as size(x_eval)
                for k = 1:numel(x_eval)
                    dx = x_eval(k) - obj.x(indexes(k));
                    y_eval(k) = obj.a(indexes(k)) + obj.b(indexes(k)) * dx + obj.c(indexes(k)) * dx^2 + obj.d(indexes(k)) * dx^3;
                end % for
            end % if method
        end % function evaluate
    end
end
