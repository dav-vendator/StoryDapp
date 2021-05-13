<script>
    export let header;
    export let data; //data
    export let downVote;
    export let upVote;
    export let id; 
    import {createEventDispatcher} from 'svelte';
    const dispatch = createEventDispatcher()
    let voteToggle = undefined;

    function dispatchUpVote(){
        if (!voteToggle || voteToggle === undefined){
            dispatch("message" , {
                vote: +1,
                id: id
            })
            if (voteToggle === false){
                voteToggle = true
                downVote = downVote-1
            }
            upVote = upVote + 1
            voteToggle = true
        }else {
            window.alert("Already UpVoted")
        }
    }

    function dispatchDownVote(){
        if (voteToggle || voteToggle === undefined){
            dispatch("message", {
                vote: -1,
                id: id
            })
            if (voteToggle === true){
                voteToggle = false
                upVote = upVote - 1
            }
            downVote = downVote + 1
            voteToggle = false
        }else{
            window.alert("Already DownVoted")
        }
    }
</script>

<div class="card border border-warning mx-auto">
    <div class="card-header">{header}</div>
    <div class="card-body">
        <p class="card-text">{@html data}</p>
    </div>
    <div class="card-footer">
        <button id="up_vote" class="btn btn-light" on:click = {dispatchUpVote}>
            Up Vote({upVote})</button>
        <button id="down_vote" class="btn btn-light" on:click={dispatchDownVote}>
            Down Vote({downVote})</button>
    </div>
</div>