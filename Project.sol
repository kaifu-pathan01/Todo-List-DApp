// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title Project - Todo List DApp Smart Contract
 * @dev A decentralized task management system allowing users to create, manage, and track tasks
 * @author Todo List DApp Team
 */
contract Project {
    
    // Structure to represent a task
    struct Task {
        uint256 id;
        string content;
        bool completed;
        uint256 createdAt;
        uint256 completedAt;
        address owner;
    }
    
    // State variables
    mapping(address => Task[]) private userTasks;
    mapping(address => uint256) private taskCounter;
    uint256 public totalTasks;
    uint256 public totalUsers;
    mapping(address => bool) private hasCreatedTask;
    
    // Events
    event TaskCreated(address indexed user, uint256 indexed taskId, string content, uint256 timestamp);
    event TaskCompleted(address indexed user, uint256 indexed taskId, uint256 timestamp);
    event TaskDeleted(address indexed user, uint256 indexed taskId, uint256 timestamp);
    
    // Modifiers
    modifier taskExists(uint256 _taskId) {
        require(_taskId < userTasks[msg.sender].length, "Task does not exist");
        _;
    }
    
    modifier validTaskContent(string memory _content) {
        require(bytes(_content).length > 0, "Task content cannot be empty");
        require(bytes(_content).length <= 500, "Task content exceeds maximum length");
        _;
    }
    
    /**
     * @dev Core Function 1: Create a new task
     * @param _content The content/description of the task
     */
    function createTask(string memory _content) 
        public 
        validTaskContent(_content) 
    {
        // Track new users
        if (!hasCreatedTask[msg.sender]) {
            hasCreatedTask[msg.sender] = true;
            totalUsers++;
        }
        
        uint256 taskId = userTasks[msg.sender].length;
        
        Task memory newTask = Task({
            id: taskId,
            content: _content,
            completed: false,
            createdAt: block.timestamp,
            completedAt: 0,
            owner: msg.sender
        });
        
        userTasks[msg.sender].push(newTask);
        taskCounter[msg.sender]++;
        totalTasks++;
        
        emit TaskCreated(msg.sender, taskId, _content, block.timestamp);
    }
    
    /**
     * @dev Core Function 2: Toggle task completion status
     * @param _taskId The ID of the task to toggle
     */
    function toggleTaskCompletion(uint256 _taskId) 
        public 
        taskExists(_taskId) 
    {
        Task storage task = userTasks[msg.sender][_taskId];
        
        if (!task.completed) {
            // Mark as completed
            task.completed = true;
            task.completedAt = block.timestamp;
            emit TaskCompleted(msg.sender, _taskId, block.timestamp);
        } else {
            // Mark as incomplete
            task.completed = false;
            task.completedAt = 0;
        }
    }
    
    /**
     * @dev Core Function 3: Delete a task
     * @param _taskId The ID of the task to delete
     */
    function deleteTask(uint256 _taskId) 
        public 
        taskExists(_taskId) 
    {
        uint256 lastIndex = userTasks[msg.sender].length - 1;
        
        // If not the last element, move the last element to the deleted position
        if (_taskId != lastIndex) {
            userTasks[msg.sender][_taskId] = userTasks[msg.sender][lastIndex];
            userTasks[msg.sender][_taskId].id = _taskId; // Update the ID
        }
        
        // Remove the last element
        userTasks[msg.sender].pop();
        taskCounter[msg.sender]--;
        totalTasks--;
        
        emit TaskDeleted(msg.sender, _taskId, block.timestamp);
    }
    
    // View functions
    
    /**
     * @dev Get all tasks for the caller
     * @return Array of all user's tasks
     */
    function getUserTasks() public view returns (Task[] memory) {
        return userTasks[msg.sender];
    }
    
    /**
     * @dev Get a specific task by ID
     * @param _taskId The ID of the task
     * @return The task details
     */
    function getTask(uint256 _taskId) 
        public 
        view 
        taskExists(_taskId) 
        returns (Task memory) 
    {
        return userTasks[msg.sender][_taskId];
    }
    
    /**
     * @dev Get user's task statistics
     * @return totalCount Total number of tasks
     * @return completedCount Number of completed tasks
     * @return pendingCount Number of pending tasks
     */
    function getUserTaskStats() 
        public 
        view 
        returns (uint256 totalCount, uint256 completedCount, uint256 pendingCount) 
    {
        Task[] memory tasks = userTasks[msg.sender];
        totalCount = tasks.length;
        completedCount = 0;
        
        for (uint256 i = 0; i < tasks.length; i++) {
            if (tasks[i].completed) {
                completedCount++;
            }
        }
        
        pendingCount = totalCount - completedCount;
    }
    
    /**
     * @dev Get global platform statistics
     * @return _totalTasks Total tasks across all users
     * @return _totalUsers Total number of users
     */
    function getPlatformStats() 
        public 
        view 
        returns (uint256 _totalTasks, uint256 _totalUsers) 
    {
        return (totalTasks, totalUsers);
    }
    
    /**
     * @dev Get tasks filtered by completion status
     * @param _completed True for completed tasks, false for pending tasks
     * @return Filtered array of tasks
     */
    function getTasksByStatus(bool _completed) 
        public 
        view 
        returns (Task[] memory) 
    {
        Task[] memory allTasks = userTasks[msg.sender];
        uint256 count = 0;
        
        // Count matching tasks
        for (uint256 i = 0; i < allTasks.length; i++) {
            if (allTasks[i].completed == _completed) {
                count++;
            }
        }
        
        // Create filtered array
        Task[] memory filteredTasks = new Task[](count);
        uint256 index = 0;
        
        for (uint256 i = 0; i < allTasks.length; i++) {
            if (allTasks[i].completed == _completed) {
                filteredTasks[index] = allTasks[i];
                index++;
            }
        }
        
        return filteredTasks;
    }
}
