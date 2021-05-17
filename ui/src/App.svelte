<script>
	import Account from "./Account.svelte";
	import Timeline from "./Timeline.svelte";
	import Event from "./Event.svelte";
	let isAvailable = (window.ethereum !== undefined);
</script>

<style>

</style>

<div class="grid-container">
	<div class="header container">
		<h1 class="display-4 app-title">StoryDAO</h1>
		<small class="lead">A decenteralized collaborative story writing app. 
			Powered by Ethereum Blockchain.
		</small>
	</div>
	<div class="information container">
		<Account isAvailable/>
	</div>
	<div class="content container">
		<Timeline/>
	</div>
	<div class="events container">
		<Event/>
	</div>
</div>
