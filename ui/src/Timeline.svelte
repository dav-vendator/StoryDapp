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
    import GreenListItem from "./GreenListItem.svelte"
    // import {ethers} from "ethers";
    // import {STToken, StoryDAO} from "./abis.js";
    // let provider = new ethers.providers.Web3Provider(window.ethereum);
    // const token = new ethers.Contract("0x5FbDB2315678afecb367f032d93F642f64180aa3",
    // STToken, provider);
    // const story = new ethers.Contract("0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512",
    // StoryDAO, provider);
    // let balance;
    let items = [1,2,3,4,5]
</script>
<!-- 
{#await balance=story.daoTokenBalance()}
    <p>Loading...</p>
{:then tokenCount}
    <p>Total Supply: {tokenCount}</p>
{:catch error}
    <p>Error: {error}</p>
{/await} -->.
<div class="container-flex mw-90">
    <div>
        <ul style="list-style-type:none">
            {#each items as item}
                <li class="pt-2">
                    <GreenListItem header={`Card Number: ${item}`} 
                        type=true data="Hello World"
                        recipient="0x0343252345" sender="0x243423542" amount="0.01" amountType="ETH"/>
                </li>
            {/each}
        </ul>
    </div>
</div>
