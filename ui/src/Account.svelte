<script>
    export let provider;
    export let signer;

    let account = window.ethereum.request({method:'eth_requestAccounts'});
</script>

{#await account}
<p>Loading account...</p>
{:then account}
<p>Welcome {account}</p>
{:catch error}
<p>Error while loading account!</p>
{/await}



