<!--
Timeline component is where live updates are posted
everytime a new event occurs it gets featured in here
with proper color coding:
1. Additions and Proposal Acceptances = Green outlined card
2. Deletion = Red Outlined card
3. Proposal added = Yellow outlined card
4. Blacklisted = Black outlined card
-->

<script>
    import {ethers} from "ethers";
    import {STToken, StoryDAO} from "./abis.js";
    let provider = new ethers.providers.Web3Provider(window.ethereum);
    const token = new ethers.Contract("0x5FbDB2315678afecb367f032d93F642f64180aa3",
    STToken, provider);
    const story = new ethers.Contract("0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512",
    StoryDAO, provider);
    let balance;
</script>
{#await balance=story.daoTokenBalance()}
    <p>Loading...</p>
{:then tokenCount}
    <p>Total Supply: {tokenCount}</p>
{:catch error}
    <p>Error: {error}</p>
{/await}