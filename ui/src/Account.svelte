<script>
    import {ethers} from "ethers";
    import {onMount} from "svelte";
    import {STToken, StoryDAO} from "./abis.js";
    import {tokenAddress, storyAddress} from "./contracts.js";
    
    import Avatars from "@dicebear/avatars";
    import identicon from "@dicebear/avatars-identicon-sprites";
    
    let provider = new ethers.providers.Web3Provider(window.ethereum);
    let account = window.ethereum.request({method:'eth_requestAccounts'});
    //These are fixed for now
    const token = new ethers.Contract(tokenAddress,
    STToken, provider);
    const story = new ethers.Contract(storyAddress,
    StoryDAO, provider);

    let ethBalance;
    let stBalance;
    let contributions;
    let deletions;
    let proposals;
    let numProposalVoted;
    let isWhitelisted;

    onMount(async() => {
        await ethereum.on('accountsChanged', function(account) {
            window.alert(`Account changed to ${account}. Please reload!`)
        })

        story.on("Whitelisted", (address, status) => {
            console.log(address, status)
            document.getElementById("whitelisted").innerText = status;
            isWhitelisted = status;
        })
        //events from ethereum are handled here as well
    })
</script>

<div class="container-flex h-25">
    {#if $$props.isAvailable}
        {#await account}
            <h4>Loading Account...</h4>
        {:then account}
                <div class="row d-flex justify-content-center">
                    {@html new Avatars(identicon).create(account.toString(),{
                        width:80,
                        height:80,
                        r:8,
                        background:"#00000"})
                    }
                </div>
                <div class="row d-flex justify-content-center pt-2">
                    <small class="greyed-caption">{account.toString()}</small>
                </div>

                {#await ethBalance=provider.getBalance(account.toString())}
                    <p>Getting Eth Balance</p>
                {:then ethBalance}
                    <div class="row d-flex justify-content-center"> 
                        {@html `<b>ETH: </b>${parseInt(ethBalance).toExponential()}`}
                    </div>
                {/await}

                {#await stBalance=token.balanceOf(account.toString())}
                    <p>Getting STToken Balance</p>
                {:then stBalance}
                    <div class="row d-flex justify-content-center"> 
                        {@html `<b>STT: </b>${parseInt(stBalance).toExponential()}`}
                    </div>
                {:catch error}
                    <p>Error: {error}</p>
                {/await}

                {#await isWhitelisted=story.whitelist(account.toString())}
                    <p>Getting whether whitelisted</p>
                {:then isWhitelisted}
                    <div class="row d-flex justify-content-center"> 
                        {@html `<b>Whitelisted: </b><span id="whitelisted">${isWhitelisted}</span>`}
                    </div>
                {:catch error}
                    <p>Error: {error}</p>
                {/await}

                {#await contributions=story.totalSubmissions(account.toString())}
                    <p>Getting total submissions</p>
                {:then contributions}
                    <div class="row d-flex justify-content-center"> 
                        {@html `<b>Submissions: </b>${contributions}`}
                    </div>
                {:catch error}
                    <p>Error: {error}</p>
                {/await}

                {#await deletions=story.deletions(account.toString())}
                    <p>Getting total deleted</p>
                {:then deletions}
                    <div class="row d-flex justify-content-center"> 
                        {@html `<b>Deletions: </b>${deletions}`}
                    </div>
                {:catch error}
                    <p>Error: {error}</p>
                {/await}

                <!--
                <dt>Proposals submitted</dt>
                <dd>0</dd>
                <dt>Proposals voted on</dt>
                <dd>0</dd>
                -->
        {/await}
    {:else}
        {console.log("Not Available!")}
    {/if}
</div>