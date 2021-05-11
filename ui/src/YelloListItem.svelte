<script>
    export let header;
    export let data; //data
    export let sender;
    export let recipient;
</script>

<div class="card border border-warning mx-auto">
    <div class="card-header">{header}</div>
    <div class="card-body">
        <p class="card-text">{@html data}</p>
    </div>
    {#if sender !== undefined && recipient !==undefined}
        <div class="card-footer border-warning">
            <b>From:</b> {sender}
            <small>To</small>
            <b>Recipient</b> {recipient}
        </div>
    {/if}
</div>