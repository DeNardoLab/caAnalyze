
sig_responses = table();
non_responses = table();

for i = 1:size(test, 1)
    excited = test.Excited(i,2);
    suppressed = test.Suppressed(i,2);
    
    if excited > 5 || suppressed > 5
        
        sig_responses = [sig_responses; test(i,:)];
        
    else
        
        non_responses = [non_responses; test(i,:)];
        
    end
    
end