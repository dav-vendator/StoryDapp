<script>
    import {ethers} from "ethers";
    import {onMount} from "svelte";
    import {STToken, StoryDAO} from "./abis.js";
    
    import Avatars from "@dicebear/avatars";
    import identicon from "@dicebear/avatars-identicon-sprites";
    
    let provider = new ethers.providers.Web3Provider(window.ethereum);
    let account = window.ethereum.request({method:'eth_requestAccounts'});
    //These are fixed for now
    const token = new ethers.Contract("0x5FbDB2315678afecb367f032d93F642f64180aa3",
    STToken, provider);
    const story = new ethers.Contract("0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512",
    StoryDAO, provider);

    let balance;
  
    onMount(async() => {
        await ethereum.on('accountsChanged', function(account) {
            window.alert(`Account changed to ${account}. Please reload!`)
        })
    })
</script>

<div class="container-flex">
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

            {#await balance=provider.getBalance(account.toString())}
                <p>Getting Eth Balance</p>
            {:then balance}
                <div class="row d-flex justify-content-center"> 
                    {@html `<b>ETH: </b>${parseInt(balance).toExponential()}`}
                </div>
            {/await}

            {#await balance=token.balanceOf(account.toString())}
                <p>Getting STToken Balance</p>
            {:then tokenCount}
                <div class="row d-flex justify-content-center"> 
                    {@html `<b>STT: </b>${parseInt(tokenCount).toExponential()}`}
                </div>
            {:catch error}
                <p>Error: {error}</p>
            {/await}
        {/await}
    {:else}
        {console.log("Not Available!")}
    {/if}
</div>