function out = taylor_matrices(A, Gamma, varargin)
%TAYLOR_MATRICES Grounded Laplacian and stability of the Taylor model.
%
%   out = TAYLOR_MATRICES(A, Gamma) computes the algebraic objects that
%   describe the equilibrium of the Taylor model
%
%       xdot = -(L[A] + Gamma) x + Gamma u,     L[A] = diag(A*1) - A.
%
%   Gamma may be given as a diagonal matrix or as a vector of susceptibility
%   rates gamma_i >= 0.
%
%   Output fields
%       gamma        n-by-1 vector of prejudice rates
%       L            Laplacian of A
%       M            grounded Laplacian L + diag(gamma)
%       eigenvalues  eigenvalues of M
%       minRealPart  smallest real part of an eigenvalue of M
%       isHurwitz    true when -M is Hurwitz, i.e. every eigenvalue of M has
%                    strictly positive real part
%       condition    condition number of M (Inf when singular)
%
%   THEORY (Part I, Theorem 18 and Corollary 19)
%       L is a SINGULAR M-matrix, so the pure Abelson model is only
%       marginally stable. Adding the anchoring term Gamma makes L + Gamma a
%       NONSINGULAR M-matrix exactly when every agent is P-dependent, and the
%       system becomes exponentially stable with the unique equilibrium
%
%           x* = (L + Gamma) \ (Gamma u),
%
%       a convex combination of the prejudices. minRealPart is the smallest
%       eigenvalue of the grounded Laplacian and sets the convergence rate.
%
%   NOTE ON THE INPUT TERM
%       The tutorial prints the matrix form of the Taylor model as
%       xdot = -(L + Gamma) x + u (Eq. 15), but consistency with Eq. (14) and
%       with the limit formula of Theorem 18 (which contains Gamma^11)
%       requires the input to be Gamma*u. This project implements Gamma*u.
%
%   See also SIM_TAYLOR, PREDICT_LIMIT_TAYLOR, TAYLOR_REDUCE, FJ_MATRICES.

    n = validate_nonnegative_matrix(A, 'A');
    gamma = diagonal_parameter(Gamma, n, 'Gamma', 0, Inf);

    parse_options(struct(), varargin, mfilename);   % reject stray arguments

    L = diag(sum(A, 2)) - A;
    M = L + diag(gamma);

    ev = eig(M);
    minRealPart = min(real(ev));

    out = struct();
    out.gamma       = gamma;
    out.L           = L;
    out.M           = M;
    out.eigenvalues = ev;
    out.minRealPart = minRealPart;
    out.isHurwitz   = minRealPart > 1e-12 * max(1, norm(M, Inf));
    if out.isHurwitz
        out.condition = cond(M);
    else
        out.condition = Inf;
    end
end
