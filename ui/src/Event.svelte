<script>
import { id } from "@ethersproject/hash";

    import {ethers} from "ethers";
    import {onMount} from "svelte";
    import {STToken, StoryDAO} from "./abis.js";
    import {tokenAddress, storyAddress} from  "./contracts.js";
    import GreenListItem from "./GreenListItem.svelte";
    import RedListItem from "./RedListItem.svelte";

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
        
        story.on("Blacklisted", (address, status) => {
            events.push({type: 1, address: address, status: status})

            let node = document.createElement("LI");                
            //Create card element blacklisted
            let listNode = document.createElement("div")

            listNode.classList.add("card")
            listNode.classList.add("border")
            listNode.classList.add("border-danger")
           
            let divHeader = document.createElement("div")
            divHeader.classList.add("card-header")

            let header = document.createTextNode(`Blacklisted`)
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
        })

        story.on("Whitelisted", (address, status) => { 
            events.push({type: 0, address: address, status: status})
            let node = document.createElement("LI");                
            //Create card element whitelisted
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
        })

        story.on("SubmissionCreated", (index, isImage, submitter) => {
            events.push({type: 2, address: submitter, isImage: isImage, index: index})
            let node = document.createElement("LI");                
            //Create card element submission created
            let listNode = document.createElement("div")

            listNode.classList.add("card")
            listNode.classList.add("border")
            listNode.classList.add("border-success")
           
            let divHeader = document.createElement("div")
            divHeader.classList.add("card-header")

            let header = document.createTextNode(`Submission Added: ${index} by ${submitter}`)
            divHeader.appendChild(header)

            let divBody = document.createElement("div")
            divBody.classList.add("card-body")

            let bodyText = document.createElement("b")
            if (isImage)
                bodyText.innerText = "Image Added"
            else
                bodyText.innerText = "Text Submission Added!"

            divBody.appendChild(bodyText)
            listNode.appendChild(divHeader)
            listNode.appendChild(divBody)
            node.appendChild(listNode); 
            node.classList.add("pt-2")
            document.getElementById("event_list").appendChild(node); 
        })

        story.on("ProposalAdded" , (id, typeFlag, description, submitter) => {

        })

        story.on("PropsalExecuted", (id) => {

        })

        story.on("Voted", (voter, vote, power, reason) => {

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
                        type=true data={item.address}
                        />
                </li>
            {:else if item.type == 1}
                <RedListItem header="Blacklisted"
                    data={item.address} />
            {:else if item.type == 2}
                <GreenListItem header = {`Submission Added : ${item.index}`}
                    type=true data = {
                        () => {
                            if (item.isImage){
                                return  "Image Added"
                            }else{
                                return "Text Submission Added"
                            }
                        }
                    }
                />
            {/if}
        {/each}
    </ul>
</div>

