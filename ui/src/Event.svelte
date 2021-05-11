<script>
    import {ethers} from "ethers";
    import {onMount} from "svelte";
    import {STToken, StoryDAO} from "./abis.js";
    import {tokenAddress, storyAddress} from  "./contracts.js";
    import GreenListItem from "./GreenListItem.svelte";
    import RedListItem from "./RedListItem.svelte";
    import YellowListItem from "./YelloListItem.svelte";

    let provider = new ethers.providers.Web3Provider(window.ethereum);
    let account = window.ethereum.request({method:'eth_requestAccounts'});
    //These are fixed for now
    const token = new ethers.Contract(tokenAddress,
    STToken, provider);
    const story = new ethers.Contract(storyAddress,
    StoryDAO, provider);

    let events = [
        {type:1, address: '0x43618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f', status: true},
        {type: 2, address: '0x45618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f', isImage: false, index: 2},
        {type: 2, address: '0x65618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f', isImage: true, index: 2},
        {type:3, id: 3, submitter: '0xfg3618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f', typeFlag: 2,
        description: 'Delete Submission at index 2'},
        {type:0, address:'0x89618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f', status: true}
    ];

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

        story.on("PropsalExecuted", (id) => {
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
</script>

<style></style>
<div class="container-flex">
    <h3>Latest Events</h3>
    <ul id="event_list" style="list-style-type: none;">
        {#each events as item}
            <li class="pt-2">
                {#if item.type == 0}    
                    <GreenListItem header="Whitelisted"
                       type=true data={item.address}
                    />
                {:else if item.type == 1}
                    <RedListItem header="Blacklisted"
                        data={item.address}/>
                {:else if item.type == 2}
                    <GreenListItem header = {`Submission Added : ${item.index}`}
                        type=true data = {
                            `${item.isImage == true? "Image Added" : "Text Submission Added"}`
                        }
                    />
                {:else if item.type == 3}
                    <!--Proposal Added-->
                    <YellowListItem header = {`${item.id} Proposal Added By ${item.submitter}`}
                        data = { `Proposal Added for ${item.typeFlag == 2? "Deletion" : " "}
                            ${item.description}`
                        }
                    />
                {:else if item.type == 4}
                    <GreenListItem header = {`${item.id} Proposal By ${item.proposal.submitter} Accepted!`}
                     type = true data = {
                          `Proposal Accepted for ${item.proposal.typeFlag == 2? "Deletion" : " "}
                           ${item.proposal.description}`
                     }
                    />
                {:else}
                    <GreenListItem header = {`${item.voter} Voted`} type = true data = {
                       `Vote(${item.vote}) received with power(${item.power})
                       ${item.reason}` 
                    }/>
                {/if}
            </li>
        {/each}
    </ul>
</div>

