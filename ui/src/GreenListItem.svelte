<script>
    export let header;
    export let type; //image=false , data=true
    export let data; //either a image link or data
    export let sender;
    export let recipient;
    export let amount;
    export let amountType; //eth or STToken
</script>

<div class="card border border-success">
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