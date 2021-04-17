<script>
    import {ethers} from "ethers";
    import Avatars from "@dicebear/avatars";
    import identicon from "@dicebear/avatars-identicon-sprites";
    let account = window.ethereum.request({method:'eth_requestAccounts'});
    let provider = new ethers.providers.Web3Provider(window.ethereum);
    let balance;


    //----utility Section
    const shortenAddress = (addr)=> {
        return `${addr.substr(0,3)}...${addr.substr(addr.length-2,addr.length)}`
    }
</script>

<div class="container float-left">
    {#if $$props.isAvailable}
        {#await account}
         <p>Loading account...</p>
        {:then account}
        <div class="flex row">  
            <div class="col pl-2">
                {@html new Avatars(identicon).create(account.toString(),{
                    width:50,
                    height:50,
                    r:64,
                    background:"#000000"
                })}
            </div>
            <div class="col justify-content-between">
                {@html `<b>Account: </b>${shortenAddress(account.toString())}</b>`}
            </div>
            <div class="col">
                {#await balance=provider.getBalance(account.toString())}
                    <p>Loading Balance</p>
                {:then balance}
                    {@html `<b>ETH: </b>${balance.toString()}`}
                {/await}
            </div>
        </div>
        
        {:catch error}
            <p>Error while loading account!</p>
        {/await}
    {:else}
        <p>Ethereum Not Working!</p>
    {/if}
</div>




