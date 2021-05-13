<script>
    export let header;
    export let data; //data
</script>

<div class="card border border-danger mx-auto">
    <div class="card-header">{header}</div>
    <div class="card-body">
        <p class="card-text">{@html data}</p>
    </div>
    <!-- {#if sender !== undefined && recipient !==undefined}
        <div class="card-footer border-danger">
            <b>From:</b> {sender}
            <small>To</small>
            <b>Recipient</b> {recipient}
        </div>
    {/if} -->
</div>