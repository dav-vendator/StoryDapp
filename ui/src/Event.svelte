<script>
    import {ethers} from "ethers";
    import {onMount} from "svelte";
    import {STToken, StoryDAO} from "./abis.js";
    import {tokenAddress, storyAddress} from  "./contracts.js";
    import GreenListItem from "./GreenListItem.svelte";

    let provider = new ethers.providers.Web3Provider(window.ethereum);
    let account = window.ethereum.request({method:'eth_requestAccounts'});
    //These are fixed for now
    const token = new ethers.Contract(tokenAddress,
    STToken, provider);
    const story = new ethers.Contract(storyAddress,
    StoryDAO, provider);

    let events = [];

    onMount(async() => {
        await ethereum.on('accountsChanged', function(account) {
            window.alert(`Account changed to ${account}. Please reload!`)
        })

        /*
        <div class="card border border-success mx-auto">
    {#if type} <!--Data--> 
        <div class="card-header">{header}</div>
        <div class="card-body">
            <p class="card-text">{@html data}</p>
        </div>
    {:else} <!--Image-->
        <img class="card-img-top" src={data} alt={`Image from ${sender}`}>
    {/if}
    {#if sender !== undefined && recipient !==undefined}
        <div class="card-footer border-success">
            <b>From:</b> {sender}
            <small>To</small>
            <b>Recipient</b> {recipient}
            <b>Amount: </b>{@html `${amount} <b>${amountType}`}
        </div>
    {/if}
</div>

        */
        story.on("Whitelisted", (address, status) => { 
            let node = document.createElement("LI");                 // Create a <li> node
            //Create card element
            let listNode = document.createElement("div")

            listNode.classList.add("card")
            listNode.classList.add("border")
            listNode.classList.add("border-success")
           

            let divHeader = document.createElement("div")
            divHeader.classList.add("card-header")

            let header = document.createTextNode(`Whitelisted`)
            divHeader.appendChild(header)

            let divBody = document.createElement("div")
            divBody.classList.add("card-body")

            let bodyText = document.createElement("b")
            bodyText.innerText = address

            divBody.appendChild(bodyText)
            listNode.appendChild(divHeader)
            listNode.appendChild(divBody)
            node.appendChild(listNode); 
            node.classList.add("pt-2")

            document.getElementById("event_list").appendChild(node);     
            events.push({type: 0, address: address, status: status})
            console.log(events)
        })
    })
</script>

<style></style>
<div class="container-flex">
    <h3>Latest Events</h3>
    <ul id="event_list" style="list-style-type: none;">
        {#each events as item}
            {#if item.type == 0}    
                <li class="pt-2">
                    <GreenListItem header="Whitelisted"
                        type=true data={`${item.address} whitelisted`}
                        recipient={storyAddress} sender={item.address} amount="0.01" amountType="ETH"/>
                </li>
            {/if}
        {/each}
    </ul>
</div>

