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

