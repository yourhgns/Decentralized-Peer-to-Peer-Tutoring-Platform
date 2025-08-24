# 📚 Decentralized Peer-to-Peer Tutoring Platform

Welcome to a revolutionary way to connect tutors and students worldwide through a trustless, blockchain-powered platform! This Web3 project addresses the real-world problem of limited access to affordable, personalized education by enabling peer-to-peer tutoring sessions paid via tokens on the Stacks blockchain. No intermediaries, transparent payments, and decentralized governance ensure fair and efficient learning experiences for everyone.

## ✨ Features

🔍 Search and match tutors based on subjects, expertise, and availability  
📅 Book and schedule tutoring sessions securely  
💰 Pay with platform tokens, held in escrow until session completion  
⭐ Rate and review tutors to build reputation  
⚖️ Resolve disputes through decentralized mechanisms  
📈 Earn tokens as a tutor or through referrals  
🔒 Immutable records of sessions, payments, and reviews  
🚀 Custom token economy for incentives and governance

## 🛠 How It Works

**For Students**  
- Register as a user and browse available tutors by subject or rating.  
- Book a session by specifying time, duration, and topic.  
- Pay with tokens, which are locked in escrow.  
- After the session (conducted off-chain via video call), confirm completion to release payment.  
- Leave a review to help the community.  

**For Tutors**  
- Register and create a profile with subjects, rates, and availability.  
- Accept booking requests from students.  
- Complete sessions and receive tokens upon student confirmation.  
- Build reputation through positive reviews to attract more students.  

**Payments and Security**  
- All transactions use the platform's native token.  
- Escrow ensures funds are only released when both parties agree.  
- Disputes can be escalated to a decentralized resolution process.  

This platform leverages 7 smart contracts written in Clarity to handle various aspects securely and efficiently.

## 📜 Smart Contracts Overview

1. **Token Contract**  
   Manages the platform's ERC-20-like fungible token (e.g., TUTOR token) for payments, rewards, and staking. Includes minting, burning, transferring, and balance queries.

2. **User Registry Contract**  
   Handles user registration, authentication, and roles (student/tutor). Stores basic profiles like wallet addresses, usernames, and verification status.

3. **Tutor Management Contract**  
   Allows tutors to create and update profiles with details like subjects taught, hourly rates, availability slots, and bio. Includes functions to query tutor listings.

4. **Session Booking Contract**  
   Facilitates booking requests, confirmations, and scheduling. Tracks session details such as time, duration, topic, and status (pending, active, completed).

5. **Escrow Contract**  
   Locks student payments in escrow during sessions. Releases funds to tutors upon successful completion or refunds in case of cancellation/dispute.

6. **Review System Contract**  
   Enables students to submit ratings (1-5 stars) and text reviews after sessions. Aggregates reputation scores for tutors and stores immutable review history.

7. **Dispute Resolution Contract**  
   Manages dispute filings, evidence submission, and resolution via simple community voting or oracle integration. Ensures fair outcomes with token penalties for bad actors.

## 🚀 Getting Started

To deploy and interact:  
- Install the Clarinet tool for Clarity development.  
- Deploy contracts to the Stacks testnet.  
- Use the Stacks wallet to mint tokens and test features.  

Example Clarity snippet for registering a tutor (from Tutor Management Contract):  
```clarity
(define-public (register-tutor (subjects (list 10 (string-ascii 50))) (rate uint) (bio (string-utf8 256)))  
  (let ((tutor-id (as-contract tx-sender)))  
    (map-set tutor-profiles tutor-id {subjects: subjects, rate: rate, bio: bio})  
    (ok true)))  
```

This project empowers global education access while fostering a token-based economy—join the decentralized learning revolution!