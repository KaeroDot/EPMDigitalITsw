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
            obj.x = t;
            obj.y = record;
            obj.n = length(t);
            [obj.a, obj.b, obj.c, obj.d] = obj.calculateCoefficients();
        end

        function [a, b, c, d] = calculateCoefficients(obj)
            % Calculate spline coefficients.
            a = obj.y;
            b = zeros(1, obj.n);
            c = zeros(1, obj.n);
            d = zeros(1, obj.n);
            h = diff(obj.x);
            alpha = zeros(1, obj.n - 2);
            % old code:
                    % for i = 2:(obj.n - 1)
                        % alpha(i-1) = (3 / h(i-1)) * (a(i + 1) - a(i)) - (3 / h(i-1)) * (a(i) - a(i - 1));
                    % end
            % faster code without for loop:
            a_ip1 = [ a  NaN NaN];
            a_i =   [NaN  a  NaN];
            a_im1 = [NaN NaN  a ];
            h_im1 = [NaN  h  NaN NaN]; % NaN two times because h is result of diff, that is shorter by 1 element
            alpha = (3 ./ h_im1) .* (a_ip1 - a_i) - (3 ./ h_im1) .* (a_i - a_im1);
            % remove excess NaNs:
            % (if user will use empty x or y or both, next line will fail. But
            % the scrip should check sane inputs at the beginning, not inside.)
            alpha = alpha(3 : end-2);

            l = ones(1, obj.n);
            mu = zeros(1, obj.n);
            z = zeros(1, obj.n);

            for i = 2:(obj.n - 1)
                l(i) = 2 * (obj.x(i + 1) - obj.x(i - 1)) - h(i - 1) * mu(i - 1);
                mu(i) = h(i) / l(i);
                z(i) = (alpha(i - 1) - h(i - 1) * z(i - 1)) / l(i);
            end
            for j = (obj.n - 1):-1:1
                c(j) = z(j) - mu(j) * c(j + 1);
                b(j) = (a(j + 1) - a(j)) / h(j) - h(j) * (c(j + 1) + 2 * c(j)) / 3;
                d(j) = (c(j + 1) - c(j)) / (3 * h(j));
            end
        end

        function results = evaluate(obj, t2)
            % Evaluate the spline at given points.
            results = zeros(1, length(t2));
            for k = 1:length(t2)
                x_eval = t2(k);
                for i = 1:(obj.n - 1)
                    if (obj.x(i) <= x_eval && x_eval <= obj.x(i + 1))
                        dx = x_eval - obj.x(i);
                        results(k) = obj.a(i) + obj.b(i) * dx + obj.c(i) * dx^2 + obj.d(i) * dx^3;
                    end
                end
            end
        end
    end
end
