module Pythia

function lasso(X, y, lambda; t = 0.1, K = 100) 
    T, p = size(X)
    bhat = zeros(p, 1)
    fhat = zeros(K-1, 1)
    
    for k in 1:K-1
        grad = X' * (X * bhat - y)/T
        v = bhat - t*grad
        bhat = max.(v .- t*lambda, 0) - max.(-v .- t*lambda, 0)            
        fhat[k] = 0.5*sum((X*bhat - y).^2)/T + lambda*sum(abs.(bhat))
    end
    
    return bhat, fhat
end  

function glasso(X, y, lambda, G0, G; t = 0.1, K = 100) 
    T, p = size(X)
    bhat = zeros(p, 1)
    fhat = zeros(K-1, 1)
    
    for k in 1:K-1
        grad = X' * (X * bhat - y)/T
        v = bhat - t*grad
        bhat0 = max.(1 - t*lambda ./ sqrt(sum(v[1:G0].^2)), 0) .* v[1:G0]
        penalty = sqrt(sum(bhat0.^2))
        bhat[1:G0] = bhat0
        for g = 1:div(p-G0, G)
            j1 = G0 + (g - 1)*G + 1
            j2 = G0 + g*G
            bhatg = max.(1 - t*lambda ./ sqrt(sum(v[j1:j2].^2)), 0) .* v[j1:j2]
            bhat[j1:j2] = bhatg
            penalty = penalty + sqrt(sum(bhatg.^2))
        end      
        fhat[k] = 0.5*sum((X*bhat - y).^2)/T + lambda*penalty
    end
    
    return bhat, fhat
end

function sglasso(X, y, lambda, alpha, G0, G; t = 0.1, K = 100) 
    T, p = size(X)
    bhat = zeros(p, 1)
    fhat = zeros(K-1, 1)
    
    for k in 1:K-1
        grad = X' * (X * bhat - y)/T
        v = bhat - t*grad
        w = max.(v .- t*lambda*alpha, 0) - max.(-v .- t*lambda*alpha, 0)
        bhat0 = max.(1 - t*lambda*(1-alpha) ./ sqrt(sum(w[1:G0].^2)), 0) .* w[1:G0]
        penalty = sqrt(sum(bhat0.^2))
        bhat[1:G0] = bhat0
        for g = 1:div(p-G0, G)
            j1 = G0 + (g - 1)*G + 1
            j2 = G0 + g*G
            bhatg = max.(1 - t*lambda*(1-alpha) ./ sqrt(sum(w[j1:j2].^2)), 0) .* w[j1:j2]
            bhat[j1:j2] = bhatg
            penalty = penalty + sqrt(sum(bhatg.^2))
        end      
        fhat[k] = 0.5*sum((X*bhat - y).^2)/T + lambda*(alpha*sum(abs.(bhat)) + (1-alpha)*penalty)
    end
    
    return bhat, fhat
end

end
