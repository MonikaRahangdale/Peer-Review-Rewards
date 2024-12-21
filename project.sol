// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PeerReviewRewards {
    // Structure for a submission
    struct Submission {
        uint256 id;
        address author;
        string contentHash;
        bool reviewed;
    }

    // Structure for a review
    struct Review {
        uint256 submissionId;
        address reviewer;
        string reviewHash;
        bool approved;
    }

    // Token balance mapping
    mapping(address => uint256) public balances;

    // Submissions and Reviews storage
    Submission[] public submissions;
    mapping(uint256 => Review) public reviews;

    // Token reward for a review
    uint256 public rewardAmount = 10;

    // Events
    event SubmissionCreated(uint256 id, address indexed author, string contentHash);
    event ReviewSubmitted(uint256 submissionId, address indexed reviewer, string reviewHash);
    event ReviewApproved(uint256 submissionId, address indexed reviewer, uint256 rewardAmount);

    // Author creates a submission
    function createSubmission(string memory contentHash) public {
        uint256 submissionId = submissions.length;
        submissions.push(Submission({
            id: submissionId,
            author: msg.sender,
            contentHash: contentHash,
            reviewed: false
        }));
        emit SubmissionCreated(submissionId, msg.sender, contentHash);
    }

    // Reviewer submits a review
    function submitReview(uint256 submissionId, string memory reviewHash) public {
        require(submissionId < submissions.length, "Invalid submission ID");
        Submission storage submission = submissions[submissionId];
        require(!submission.reviewed, "Submission already reviewed");

        reviews[submissionId] = Review({
            submissionId: submissionId,
            reviewer: msg.sender,
            reviewHash: reviewHash,
            approved: false
        });

        emit ReviewSubmitted(submissionId, msg.sender, reviewHash);
    }

    // Author approves a review and rewards the reviewer
    function approveReview(uint256 submissionId) public {
        require(submissionId < submissions.length, "Invalid submission ID");
        Submission storage submission = submissions[submissionId];
        require(msg.sender == submission.author, "Only the author can approve reviews");
        require(!submission.reviewed, "Submission already reviewed");

        Review storage review = reviews[submissionId];
        require(review.submissionId == submissionId, "Review does not exist");

        review.approved = true;
        submission.reviewed = true;

        // Reward the reviewer
        balances[review.reviewer] += rewardAmount;

        emit ReviewApproved(submissionId, review.reviewer, rewardAmount);
    }

    // Check balance of tokens for an address
    function getBalance(address account) public view returns (uint256) {
        return balances[account];
    }
}