<script>
    import {ethers} from "ethers";
    import {onMount} from "svelte";
    import {STToken, StoryDAO} from "./abis.js";
    //These are fixed for now
    import {tokenAddress, storyAddress} from "./contracts.js";
    //TODO: Change this to Rinkeby
    let provider = new ethers.providers.Web3Provider(window.ethereum);
    let account = window.ethereum.request({method:'eth_requestAccounts'});
    let _localProvider = new ethers.providers.JsonRpcProvider();
    let signer =  _localProvider.getSigner(0);
    const token = new ethers.Contract(tokenAddress,
    STToken, signer);
    const story = new ethers.Contract(storyAddress,
    StoryDAO, signer);

    //  function createSubmission(bytes memory _content, bool _image)
    let submitStory = async () =>{
        let textArea = document.getElementById("submission_text").value;
        let hexString = ethers.utils.formatBytes32String(textArea);
        let amount = await story.getSubmissionFee();
        story.createSubmission(hexString,false, {value: amount}).then(
            () => {
                document.getElementById("submission_text").value = ""
                window.alert("Submission Success!")
            }
        ).catch(error => {console.log(error)})
    }
</script>

<style>

</style>

<div class="card border border-success">
    <div class="card-header">
        <b>Your Story!</b>
    </div>
    <textarea name="submission_input" 
    class="mx-auto pt-6" placeholder="Submission (Add img:<path> for image)"
    id="submission_text" row="10" style="height:100px; width:98%"/>
    <button on:click={submitStory} id="submission-body-btn" class="btn btn-light">Submit</button>
</div>