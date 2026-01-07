# ⚠️ WARNING

Due to **Pinata free account limitations**, IPFS gateway requests may fail or be rate-limited when uploading images or metadata.  Minting might be slow or temporarily unavailable if too many requests are made.

# CPSC 559 FINAL Project

Team members
- Nick Tran - CWID: 888110590 - Email: [nghitran@csu.fullerton.edu]
- Victor Vu - CWID: 887249621 - Email: [vuvictor@csu.fullerton.edu]
- Caroline Ha - CWID: 885136382 - Email: [carolineh@csu.fullerton.edu]
- Aaron Tang - CWID: 889433579 - Email: [aarontang@csu.fullerton.edu]
- Kumuda Valli V - CWID: 848379590 - Email: [vkv2909@csu.fullerton.edu]

## Overview
This is a **Truffle-based blockchain project** with smart contracts and a front-end interface.  
Users can **draw their own fish**, and an AI model will **instantly detect if it is a fish**.  
Once verified, the fish can be **minted as an NFT** and **displayed on the front-end gallery**, 
where users can **vote for their favorites** to boost their Hot ranking or tip creators via **boost** 
payments. Creators can manage their works by **gifting** them for free, **burning** (destroying) NFTs, 
**editing metadata**, **listing for sale**, and **claiming rewards** from the platform, including 
pending boost shares and bonuses.. The gallery supports sorting by votes, IDs, create time, etc, 
making it easy to explore and discover interesting fish NFTs.

---

## Features

- **1. Draw**
  - Hand-draw your own fish on a canvas.

- **2. AI Detect**
  - Instantly check if the drawing is a fish.

- **3. FinVerse Tank**
  - Watch all minted fish come to life in FinVerse Tank.

- **4. Mint**
  - Mint your fish as an NFT.
  - Condition: AI detection probability must be greater than 60%.
  - Show the minted fish profile.
  - Init the score of your fish with fish probablity.

- **5. MetaData Edit**
  - Edit fish names and traits for your owned NFTs.

- **6. Personal Gallery Management**
  - View all your minted fish in a personal gallery.
    - Gift your NFT items to others.
    - Burn (destroy) your NFT items.
    - List your fish for sale.
    - Claim Boost tips and Bonus from other users.

- **7. FinVerse Gallery**
  - View and interact with all minted fish in the public FinVerse gallery.
    - Sort fish by your preference.
    - Vote for your favorite fish.
      -Highlights the top 3 NFTs as "Hot" based on vote count, creator boost count, and total score.
    - Like for increasing score in the gallery for your favorite fish.
    - Boost for supporting other creators.
      - Users boost NFTs (0.05 ETH; half to bonus pool, half to creator).
      - User claim boost tips and bonus(1–10% of bonus pool) thru their own gallery.

- **8. Reward / Claim**
  - Rewards System
   - Mass claim of rewards.
   - Individual claim of rewards.
   - Balance statistics + # of claims left for NFT.
   
- **9. Marketplace**
  - View all fish listed for sale.
    - Update listing price or cancel listing as a seller.
    - Buy fish from a different account.

---

## Prerequisites
Make sure you have:

- **Node.js** (v16+)  
- **npm**  
- **Truffle**  
- **Ganache** (optional, for local testing)  
- **Ethereum wallet** (e.g., MetaMask)

---

## Quick Setup

1. **Clone the repository**  
2. **Install dependencies** with npm  
3. **Compile smart contracts**  
4. **Deploy contracts** to a local network (e.g., Ganache)  

---

## Credits
- ** AI model and Canvas UI: Alden Hallak- https://github.com/aldenhallak/fishes
