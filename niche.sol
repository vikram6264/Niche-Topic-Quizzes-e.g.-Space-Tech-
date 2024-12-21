// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NicheTopicQuizzes {
    struct Quiz {
        uint256 id;
        string topic;
        string question;
        string[4] options;
        uint8 correctAnswer;
        uint256 reward;
        address creator;
    }

    uint256 public quizCount;
    mapping(uint256 => Quiz) public quizzes;
    mapping(uint256 => mapping(address => bool)) public quizParticipation;
    address public owner;

    event QuizCreated(uint256 indexed quizId, string topic, address indexed creator);
    event QuizAnswered(uint256 indexed quizId, address indexed participant, bool success);
    event RewardClaimed(address indexed participant, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createQuiz(
        string memory topic,
        string memory question,
        string[4] memory options,
        uint8 correctAnswer,
        uint256 reward
    ) public payable {
        require(msg.value >= reward, "Insufficient reward amount.");
        require(correctAnswer < 4, "Invalid correct answer index.");

        quizCount++;
        quizzes[quizCount] = Quiz(
            quizCount,
            topic,
            question,
            options,
            correctAnswer,
            reward,
            msg.sender
        );

        emit QuizCreated(quizCount, topic, msg.sender);
    }

    function answerQuiz(uint256 quizId, uint8 selectedOption) public {
        require(quizId > 0 && quizId <= quizCount, "Quiz does not exist.");
        require(!quizParticipation[quizId][msg.sender], "You have already participated.");
        require(selectedOption < 4, "Invalid option selected.");

        Quiz storage quiz = quizzes[quizId];
        quizParticipation[quizId][msg.sender] = true;

        if (selectedOption == quiz.correctAnswer) {
            payable(msg.sender).transfer(quiz.reward);
            emit RewardClaimed(msg.sender, quiz.reward);
            emit QuizAnswered(quizId, msg.sender, true);
        } else {
            emit QuizAnswered(quizId, msg.sender, false);
        }
    }

    function withdrawFunds() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    receive() external payable {}
}