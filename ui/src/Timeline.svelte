<!--
Timeline component renders submissions added.
Green card are used to indicate new submission
while border (dashed) is used to indicate chapter end
-->
<script>
    import {ethers} from "ethers";
    import {onMount} from "svelte";
    import {STToken, StoryDAO} from "./abis.js";
    import {tokenAddress, storyAddress} from  "./contracts.js";
    import GreenListItem from "./GreenListItem.svelte";
    import StorySubmission from "./StorySubmission.svelte";
    let provider = new ethers.providers.Web3Provider(window.ethereum);
    let account = window.ethereum.request({method:'eth_requestAccounts'});
    const token = new ethers.Contract(tokenAddress,
    STToken, provider);
    const story = new ethers.Contract(storyAddress,
    StoryDAO, provider);
    let submissionZeroFee;
    story.submissionZeroFee().then(result => {
        submissionZeroFee = result
    })
    let submissions = [];
    /*
     event SubmissionCreated(uint256 _index, bytes _content, bool _image, address _submitter);
     event SubmissionDeleted(uint256 _index, bytes _content, bool _image, address _submitter);

    */
   let fromSubmission =  (submission) =>{
      let message = ethers.utils.parseBytes32String(submission["content"])
      console.log(submission["index"])
       return {
            image: submission["image"],
            title: message.toUpperCase().split(' ').slice(0,2).join(" "),
            data: message,
            reciver: storyAddress,
            sender: submission["submitter"],
            amount: parseInt((submissionZeroFee.mul(submission["index"])).toString()).toExponential(),
            amountType: 'STT'
       }
   }
    let loadAllSubmissions = async () => {
        submissions.splice(0, submissions.length)
        let subHashes = await story.getAllSubmissionHashes();
        console.log(`Length: ${subHashes.length}`)
        for (let hash of subHashes){
            story.getSubmission(hash).then(submission => {
                submissions = [...submissions, fromSubmission(submission)]
            })
        }

    }

    onMount(async () => {
        loadAllSubmissions();
        story.on("SubmissionCreated", async function (index, content, image, submitter, value) {
           console.log(`${index}==${ethers.utils.parseBytes32String(content)}==Image:${image}==${submitter}`)
           console.log("Received")
           console.log(value)
           let message = ethers.utils.parseBytes32String(content)
           submissions = [...submissions, {
               image: image,
               title: message.toUpperCase().split(' ').slice(0,2).join(" "),
               data: message,
               reciver: storyAddress,
               sender: submitter,
               amount: value,
               amountType: 'STT'
           }]
        })
    })
</script>

<style>
  .line {
    margin:5px 0;
    height:2px;
    background:
        repeating-linear-gradient(to right,black 0,black 5px,transparent 5px,transparent 7px)
        /*5px red then 2px transparent -> repeat this!*/
  }

</style>
<!-- 
 -->.
<div>
    <h3>Submissions</h3>
    <ul style="list-style-type: none;">
        <li>
            <StorySubmission/>
        </li>
        {#each submissions as item}
            <li class="pt-2">
                <GreenListItem header={item.title}
                type={item.image} data={item.data}
                recipient={item.reciver} sender={item.sender}
                amount={item.amount} amountType={item.amountType}/>
                {#if item.image}
                    <div class="line"></div>
                {/if}
            </li>
        {/each}
    </ul>
</div>

