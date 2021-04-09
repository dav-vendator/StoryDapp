<script>
	import {ethers} from "ethers";
	import Account from "./Account.svelte";
	//let isAvailable = window.ethereum !== undefined;
	const provider = new ethers.providers.Web3Provider(window.ethereum);
	const signer = provider.getSigner();
	//let account = window.ethereum.request({method:'eth_requestAccounts'})
</script>

<style>

</style>
<!--Structure-->
<div class="container-fluid">
	<div class="text-center">
		<h1>Story DAO</h1>
	</div>
	<div class="row pt-4">
		<div class="col-8 col-sm-8 col-lg-8">
			<p>This is a col</p>
		</div>
		<div class="col-4 col-sm-4 col-ls-4">
			<div class="row">
				<Account provider=provider signer=signer/>
			</div>
			<div class="row">
				<p>This is third row</p>
			</div>
		</div>
	</div>
</div>