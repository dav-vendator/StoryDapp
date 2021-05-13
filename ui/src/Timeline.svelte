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
    import StorySubmission from "./StorySubmission.svelte";
    let provider = new ethers.providers.Web3Provider(window.ethereum);
    let account = window.ethereum.request({method:'eth_requestAccounts'});
    const token = new ethers.Contract(tokenAddress,
    STToken, provider);
    const story = new ethers.Contract(storyAddress,
    StoryDAO, provider);
    let submission = [];
    onMount(async () => {
        
    })
    let items = [
        {image: false, title: "Tortoise And Hare", 
        data: "Once there was a hare. He was very proud of his speed. He had a tortoise friend...",
        reciver: storyAddress, sender: "0x2343425nffgfgdfhdfdh", 
        amount: "0.02", amountType: "STT"},
        {image: true, title: "Blue Flower", 
        data: "./ui/public/assets/blue_flower.jpeg",
        reciver: storyAddress, sender: "0x2343425nffgfgdfhdfdh", 
        amount: "0.02", amountType: "STT"},
        {image: false, title: "A Quick Brown Fox", 
        data: "A Quick Brown Fox Jumped over a lazy Goat",
        reciver: storyAddress, sender: "0x2343425nffgfgdfhdfdh", 
        amount: "0.02", amountType: "STT"},
        {image: false, title: "A Thirsty Crow", 
        data: "Once there was a crow. He was very thirsty.",
        reciver: storyAddress, sender: "0xfdfsdfsdgssddg", 
        amount: "0.67", amountType: "STT"}
    ]
</script>
<!-- 
 -->.
<div>
    <h3>Submissions</h3>
    <ul style="list-style-type: none;">
        <li>
            <StorySubmission/>
        </li>
        {#each items as item}
            <li class="pt-2">
                <GreenListItem header={item.title}
                type={item.image} data={item.data}
                recipient={item.reciver} sender={item.sender}
                amount={item.amount} amountType={item.amountType}/>
            </li>
        {/each}
    </ul>
</div>

