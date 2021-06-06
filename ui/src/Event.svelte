<script>
    import {ethers} from "ethers";
    import {onMount} from "svelte";
    import {STToken, StoryDAO} from "./abis.js";
    import {tokenAddress, storyAddress} from  "./contracts.js";
    import GreenListItem from "./GreenListItem.svelte";
    import RedListItem from "./RedListItem.svelte";
    import VoteListItem from "./VoteListItem.svelte";
    let provider = new ethers.providers.Web3Provider(window.ethereum);
    let account = window.ethereum.request({method:'eth_requestAccounts'});
    //These are fixed for now
    const token = new ethers.Contract(tokenAddress,
    STToken, provider);
    const story = new ethers.Contract(storyAddress,
    StoryDAO, provider);

    let events = []

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

            let bodyText = document.createTextNode(address)

            divBody.appendChild(bodyText)
            listNode.appendChild(divHeader)
            listNode.appendChild(divBody)
            node.appendChild(listNode); 
            node.classList.add("pt-2")
            document.getElementById("event_list").appendChild(node);     
        })

        story.on("SubmissionCreated", (index, isImage, submitter) => {
            console.log("Submission!!")
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
            events.push({type: 3, id: id, address: submitter, 
                typeFlag: typeFlag, description: description})
            let node = document.createElement("LI");                
            //Create card element whitelisted
            let listNode = document.createElement("div")

            listNode.classList.add("card")
            listNode.classList.add("border")
            listNode.classList.add("border-warning")
           
            let divHeader = document.createElement("div")
            divHeader.classList.add("card-header")

            let header = document.createTextNode(`${id} Proposal Added By ${submitter}`)
            divHeader.appendChild(header)

            let divBody = document.createElement("div")
            divBody.classList.add("card-body")

            let bodyText = document.createTextNode(
                `Proposal Added for ${typeFlag == 2? "Deletion" : " "}
                 ${description}
                `
            )
            divBody.appendChild(bodyText)
            listNode.appendChild(divHeader)
            listNode.appendChild(divBody)
            node.appendChild(listNode); 
            node.classList.add("pt-2")
            document.getElementById("event_list").appendChild(node); 
        })

        story.on("ProposalExecuted", (id) => {
            let proposal
            for (let i=0; i < events.length; i++){
                if (events[i].type == 3)
                    if (events[i].id = id){
                        proposal = events[i]
                        break
                    }
            }
            events.push({type:4, id:id, proposal: proposal})

            let node = document.createElement("LI");                
            //Create card element whitelisted
            let listNode = document.createElement("div")

            listNode.classList.add("card")
            listNode.classList.add("border")
            listNode.classList.add("border-success")
           
            let divHeader = document.createElement("div")
            divHeader.classList.add("card-header")

            let header = document.createTextNode(`${id} Proposal By ${proposal.submitter} Accepted!`)
            divHeader.appendChild(header)

            let divBody = document.createElement("div")
            divBody.classList.add("card-body")

            let bodyText = document.createTextNode(
                `Proposal Accepted for ${typeFlag == 2? "Deletion" : " "}
                 ${description}
                `
            )
            divBody.appendChild(bodyText)
            listNode.appendChild(divHeader)
            listNode.appendChild(divBody)
            node.appendChild(listNode); 
            node.classList.add("pt-2")
            document.getElementById("event_list").appendChild(node); 
        })

        story.on("Voted", (voter, vote, power, reason) => {
            //get vote count and update
            events.push({type:5, voter: voter, vote: vote, power: power, reason: reason})
            let node = document.createElement("LI");                
            //Create card element whitelisted
            let listNode = document.createElement("div")

            listNode.classList.add("card")
            listNode.classList.add("border")
            listNode.classList.add("border-warning")
           
            let divHeader = document.createElement("div")
            divHeader.classList.add("card-header")

            let header = document.createTextNode(`${voter} Voted`)
            divHeader.appendChild(header)

            let divBody = document.createElement("div")
            divBody.classList.add("card-body")

            let bodyText = document.createTextNode(
                `Vote(${vote}) received with power(${power})
                 ${reason}
                `
            )
            divBody.appendChild(bodyText)
            listNode.appendChild(divHeader)
            listNode.appendChild(divBody)
            node.appendChild(listNode); 
            node.classList.add("pt-2")
            document.getElementById("event_list").appendChild(node); 
        })

    })

    //--Vote click handler
    let onVote = (vote) => {
        console.log(`Voted: ${vote.detail.vote} on ${vote.detail.id}`)
    }
</script>

<style></style>
<div class="container-flex">
    <h3>Latest Events</h3>
    <ul id="event_list" style="list-style-type: none;">
        {#each events as item}
            <li class="pt-2">
                {#if item.type == 0}    
                    <GreenListItem header="Whitelisted"
                       type={false} data={item.address}
                       recipient = {undefined} sender = {undefined}
                       amountType = {undefined} amount = {undefined}
                    />
                {:else if item.type == 1}
                    <RedListItem header="Blacklisted"
                        data={item.address}/>
                {:else if item.type == 2}
                    <GreenListItem header = {`Submission Added : ${item.index}`}
                        type={false} data = { `${item.isImage == true? "Image Added" : "Text Submission Added"}`}
                        recipient = {undefined} sender = {undefined}
                        amountType = {undefined} amount = {undefined}
                    />
                {:else if item.type == 3}
                    <VoteListItem on:message={onVote} header = {`${item.id} Proposal Added By ${item.submitter}`}
                        id = {item.id}
                        data = { `Proposal Added for ${item.typeFlag == 2? "Deletion" : " "} ${item.description}` }
                        upVote = {20}
                        downVote = {10}/>
                {:else if item.type == 4}
                    <GreenListItem header = {`${item.id} Proposal By ${item.proposal.submitter} Accepted!`}
                     type={false} data = {
                          `Proposal Accepted for ${item.proposal.typeFlag == 2? "Deletion" : " "}
                           ${item.proposal.description}`} 
                           recipient = {undefined} sender = {undefined}
                           amountType = {undefined} amount = {undefined}
                    />
                {:else}
                    <GreenListItem header = {`${item.voter} Voted`} type = {false} data = {
                       `Vote(${item.vote}) received with power(${item.power})
                       ${item.reason}` } recipient = {undefined} sender = {undefined}
                        amountType = {undefined} amount = {undefined}/>
                {/if}
            </li>
        {/each}
    </ul>
</div>

