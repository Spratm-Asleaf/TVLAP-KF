%{
Readers are allowed to edit and distribute this file, only for academic purpose.
But if you decide to use the materials in this file, you are strongly suggested to
also share your codes (e.g., those related to your publications) with publics.

@Information:
Online supplementary materials of the paper titled 
"A Model for Non-Stationary Time Series and Its Applications in Filtering and Anomaly Detection"
Authored By: Shixiong Wang, Chongshou Li, and Andrew Lim
From: the Department of Industrial Systems Engineering and Management, National University of Singapore

@Author: Shixiong Wang
@Date: 6 July 2020
@Email: s.wang@u.nus.edu; wsx.gugo@gmail.com

See also: https://github.com/Spratm-Asleaf/Range-Correction
%}


function [Info, Err] = KFPolynomial(Z, N, T, Q, MeaThres, COUNT)
    %% Kalman Filter
    F = [];     % Phi in Eq. (12)
    f_vec = [];
    for i = 1:N
        f_vec = [f_vec T^(i-1)/factorial(i-1)];
    end

    F = [F; f_vec];
    for i = 2:N
        F = [F; [zeros(1, i-1) f_vec(1:N-i+1)]];
    end

    G = F;     % G in Eq. (12)
    G = G(:,end);

    H = [1 zeros(1,N-1)];     % H in Eq. (12)

    R = (0.05/3)^2;     % R in Eq. (12)

    P = eye(N, N)*1e5;
    X = zeros(N, 1) + 0.0000001;

    len = length(Z);
    XRecord = zeros(N,len);
    PRecord = cell(1,len);
    Err     = zeros(1,len);
    
    %% Signal Processing Paras
    InitSignalExceptionCount = 3;
    isSignalException = false;

    outlier_count = 0;
    for i = 1:len
        %% Measurement
        if InitSignalExceptionCount >= 0
            InitSignalExceptionCount = InitSignalExceptionCount - 1;
            if InitSignalExceptionCount < 0
                isSignalException = true;
            end
        end
        
        %% Kalman
        X = F*X;
        Z_ = H*X;
        Err(i) = Z_ - Z(i);
        if isSignalException
            % See Section IV, Subsection C
            % Note: If the predicted measurement is  far  away  from  the  collected  one,  
            % we  can  identify  thecollected  value  as  an  outlier/dropout  and  
            % replace  it  with  thepredicted  value.
            if abs(Z_ - Z(i)) > MeaThres
                zz = Z_;
                outlier_count = outlier_count + 1;
            else
                zz = Z(i);
                outlier_count = 0;
            end
            
            % The remedy strategy used in Fig. 10 (b)
            if outlier_count >= COUNT
                zz = Z(i);
                outlier_count = 0;
            end
        else
            zz = Z(i);
        end

        P = F*P*F' + G*Q*G';

        K = P*H'*(H*P*H' + R)^-1;
        X = X + K*(zz - Z_);

        XRecord(:,i) = X;

        P = (eye(N,N) - K*H)*P*(eye(N,N) - K*H)' + K*R*K';

        PRecord{i} = P;
    end
    
    Info.X = XRecord;
    Info.P = PRecord;
end