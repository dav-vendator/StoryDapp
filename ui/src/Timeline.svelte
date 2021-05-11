<!--
Timeline component renders submissions added.
Green card are used to indicate new submission
while border (dashed) is used to indicate chapter end
-->
<script>
    import {ethers} from "ethers";
    import {onMount} from "svelte";
    import {STToken, StoryDAO} from "./abis.js";
    import {tokenAddress, storyAddress} from  "./contracts.js";
    import GreenListItem from "./GreenListItem.svelte";

    let submission = [];
    
    let items = [1,2,3,4,5,7,8]
</script>
<!-- 
 -->.
<div>
    <h3>Submissions</h3>
    <ul style="list-style-type: none;">
        {#each items as item}
            <li class="pt-2">
                <GreenListItem header={`Card Number: ${item}`} 
                    type=true data="Hello World"
                    recipient="0x0343252345" sender="0x243423542" amount="0.01" amountType="ETH"/>
            </li>
        {/each}
    </ul>
</div>

