% 2016, State Key Laboratory of Networking and Switching Technology, Beijing University of Posts and Telecommunications, Beijing, China
% Address: P.O. Box 206, No.10, Xi Tu Cheng Road, Haidian District, Beijing 100876, China. 
% Author: Haoqiu Huang (francesco@bupt.edu.cn) & Weiwei Zheng (zhengweiwei@bupt.edu.cn) 

classdef CacheLCE 
    properties
        C;
        requests;
        cache_size;
        N;
        CHP;
        Nreq;
        missTrace;       
    end 
    methods        
        function obj=CacheLCE(requests, cache_size)
            obj.C = zeros(cache_size, 1);
            obj.requests= requests;
            obj.cache_size=cache_size;
            obj.N = numel(unique(requests(:,2)));
            obj.CHP = zeros(obj.N, 2);
            obj.Nreq = length(requests(:,1));
            obj.missTrace = NaN(obj.Nreq, 2);
        end       
        function obj=run_Cache(obj)
            idx = 1;
            for i=1:obj.Nreq
                id_curr = obj.requests(i,2);
                obj.CHP(id_curr,1) = obj.CHP(id_curr,1) + 1;
                 k=find(obj.C(:,1)==id_curr);
                 if (numel(k)~=0) 
                    obj.CHP(id_curr,2) = obj.CHP(id_curr,2) + 1;
                    obj.C = obj.LruAdd(obj.C,id_curr);               
                else 
                     obj.missTrace(idx, :) = obj.requests(i,:);
                     idx = idx + 1;
                    obj.C = obj.LruAdd(obj.C, id_curr);
                 end
            end
            cut_idx = find(isnan(obj.missTrace(:, 1)), 1, 'first');
            if ~isempty(cut_idx)
                obj.missTrace = obj.missTrace(1:cut_idx-1, :); 
            end
        end               
       function C=LruAdd(~, C, id)
             k=find(C==id);
             if numel(k>0)
                  if k>1
                       C=[id; C(1:k-1); C(k+1:end)];
                   end
             else
                 C=[id; C(1:end-1)];
             end
       end      
       function hit=average_HitRate(obj)
           hit=( size(obj.requests,1)-size(obj.missTrace,1) ) / size(obj.requests,1);
       end
       function hit_eachItem=eachItem_HitRate(obj)
           hit_eachItem=obj.CHP(:, 2)./obj.CHP(:, 1);
       end       
       function missTrace=get_MissTrace(obj)
           missTrace=obj.missTrace;
       end      
    end    
end