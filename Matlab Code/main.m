clc;
clear;
close all;
warning ('off','all');
%% Reading Data
disp(['Reading Data File....']);
[node_1, node_2, trust_value] = textread('AdvogatoDataset.txt', '%d%d%f','delimiter',' ');
inputData_1 = [node_2 node_1  trust_value];
inputData_2 = [trust_value node_2 node_1];% Inverse columns is needed for some codes
inputData_3 = [node_1 node_2 trust_value];
maxNodeNumbers = max(max(node_1), max(node_2));
disp(['Making Neighborhood_DataMatrix ....']);
neighborhood_DataMatrix = {};
for i=1 : maxNodeNumbers
    trust_value_Array = inputData_2(inputData_2(:,2) == i);
    sumOfTrust = sum(trust_value_Array);
    neighborhood_Array = inputData_1(inputData_1(:,2) == i);
    neighborhood_DataMatrix = [neighborhood_DataMatrix; [i, sumOfTrust, neighborhood_Array']];
end

startNode = input('Insert number of START node: ');
endNode = input('Insert number of END node: ');

disp(['Finding Route....']);
%% Init queue
node_queue  = [];
head = 1;
node_queue(head) = startNode;
route = [];
RouteFound_Flag = false;
watchList = [node_queue(head)];
%% Main Loop
while(true)
    if isempty(node_queue) == true
        disp(['node_queue is empty. There is no route to endNode.']);
        break; 
    end 
   
    currentNode = node_queue(head);
    if currentNode == endNode
        disp(['endNode is found.']);
        RouteFound_Flag = true;
        break; 
    end  
    
    currentNode_Entry = neighborhood_DataMatrix(currentNode);
    currentNode_Neighborhoods = currentNode_Entry{1}(3:numel(currentNode_Entry{1}));
    unique_Array = unique(currentNode_Neighborhoods);% Remove duplicate entry
    intersect_Array = intersect(watchList, unique_Array);
   
    node_queue(head) = [];
    unique_Array = unique_Array(~ismember(unique_Array, intersect_Array));%Remove intersect entry
    
    watchList = [watchList unique_Array];
    watchList = unique(watchList);
    %% sort by trust_value
    tmp_Trust_Array = [];
    for i=1:numel(unique_Array)
        tempNode = neighborhood_DataMatrix(unique_Array(i));
        tmp_Trust_Array = [tmp_Trust_Array tempNode{1}(2)];
    end
    [tmp_Trust_Array index] = sort(tmp_Trust_Array,'ascend');
    sorted_unique_Array = unique_Array(index);% Sort unique_Array by index of tmp_Trust_Array
    node_queue(end+1 : end+numel(sorted_unique_Array)) = sorted_unique_Array;
    head = numel(node_queue);

    route = [route currentNode];
    LNR_Entry = neighborhood_DataMatrix(route(end));%LNR = Last Node of Route
    LNR_Neighborhoods = LNR_Entry{1}(3:numel(LNR_Entry{1}));
    intersectOfLNR_queue = intersect(LNR_Neighborhoods, node_queue);
    if isempty(intersectOfLNR_queue) == true
        route(end) = [];
    end
end% End of while

if RouteFound_Flag == true
    route =[route endNode];
    disp(['Route sequence: ' num2str([route])]);

    trustRoute_Array = [];
    for i = 1:numel(route)-1 
        temp_Array = inputData_3(inputData_3(:,1) == route(i), :);
        temp_Array = temp_Array(temp_Array(:,2) == route(i+1), :);
        temp_Array = temp_Array(:,3);
        trustRoute_Array = [trustRoute_Array max(temp_Array)];
    end
    disp(['Trust value between start and end node: ' num2str(mean(trustRoute_Array))]);
end
