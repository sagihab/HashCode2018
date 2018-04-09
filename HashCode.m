clc
close all
clear all

tic

name{1} = 'a_example';
name{2} = 'b_should_be_easy';
name{3} = 'c_no_hurry';
name{4} = 'd_metropolis';
name{5} = 'e_high_bonus';
Cscore = 0;
%% Starting loop 
for nn = 1:5
    fileID = fopen(['in/',name{nn},'.in'],'r');
    A = fscanf(fileID,'%d',[1 , 6]);
    R = A(1); C = A(2); F = A(3); N = A(4); B = A(5); T = A(6); 
    V_tag = fscanf(fileID,'%d',[6 , N])';
    V_tag = [V_tag,(1:N)'];
    fclose(fileID);
    
    best_scores = 0;
    
    for a = 1:2
    
    V = V_tag;
    sparse_perm = sparse(F , N);  
    current = zeros(F , 2);
    steps = zeros(F , 1);
    distance = sum(abs(V(:,3:4)-V(:,1:2)),2);
    max_distance = max(distance);
    
    scores = zeros(F,1);
        
    while (sum(~isnan(V(:,1))) > 0)
        [ ~ , f] = min(steps);
        if (steps(f) > T); break; end
        good_steps = steps(steps <= max(max(V(:,5) ,V(:,6) - distance)));
        if (isempty(good_steps));break;end
        
        if (a == 1)
            [ val , ~] = min(good_steps);
        else
            [ val , ~] = max(good_steps);
        end
        
        f = find(steps == val,1);
           
        if (sum(~isnan(V(:,1))) == 0); break; end
        dist_v = abs(V(:,1) - current(f,1)) + abs(V(:,2) - current(f,2));
        score1 = V(:,5)  - steps(f) - dist_v;
        score2 = V(:,6)  - max(V(:,5) , steps(f) + dist_v) - distance;

        score = -dist_v;
        % if no bonus just get in time
        if (sum(score2 >= 0) > 0)
            score = (score2 >= 0).*(score2 + distance - dist_v);
        end

        % get bonus
        if (sum((score1 >= 0).*(score1 < max_distance)) > 0)
            score = (score1 >= 0).*(distance + B - score1); 
        end

        [val , idx] = max(score);

        sparse_perm(f,1 + numel(find(sparse_perm(f,:)))) = V(idx,7);            
        current(f,:) = V(idx,3:4);
        earnb = 0;
        steps(f) = steps(f) + dist_v(idx);
        if (steps(f) <= V(idx,5))
            scores(f) = scores(f) + distance(idx) + B;
            steps(f) = V(idx,5);
            earnb = 1;
        end
        steps(f) = steps(f) + distance(idx);
        if (~earnb && steps(f) <= V(idx,6))
            scores(f) = scores(f) + distance(idx);
        end
        V(idx,:) = [];
        distance(idx) = [];
    end
    
    
    if (best_scores < sum(scores))

    fileID = fopen(['out/',name{nn} , '.out'],'w');
    for f = 1:F
        nr = numel(find(sparse_perm(f,:)));
        if(nr == 0); continue; end
        vec = full(sparse_perm(f,1:nr)) - 1;
        fprintf(fileID,'%d ',[nr , vec]);
        fprintf(fileID,'\r\n');
    end
    fclose(fileID);
%     fprintf("found new maximum ");
    best_scores = sum(scores);
    end
    
%     fprintf("%s %d\n",name{nn}, sum(scores));
    end
    
    fprintf("best scores %s %d\n",name{nn},best_scores);    
    Cscore = Cscore + best_scores;
    
end

fprintf("All score == %d\n", Cscore);
toc

