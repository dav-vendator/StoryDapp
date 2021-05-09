<script>
	import Account from "./Account.svelte";
	import Timeline from "./Timeline.svelte";
	import Event from "./Event.svelte";
	let isAvailable, wallet;
	isAvailable = (window.ethereum !== undefined);
</script>

<style>

</style>

<div class="grid-container">
	<div class="header container">
			<h1 class="display-4 app-title">StoryDAO</h1>
			<small class="lead">A decenteralized collaborative story writing app.</small>
	</div>
	<div class="information container">
		<Account isAvailable/>
	</div>
	<div class="content container">
		<Timeline/>
		<!--Content-->
	</div>
	<div class="events container">
		<Event/>
	</div>
</div>
<!--Structure-->
<!-- <header>
	<div class="container-fluid mw-100">
		<div class="jumbotron bg-dark text-white text-center fixed">
			<h1 class="display-4 app-title">StoryDAO</h1>
			<small class="lead">A decenteralized collaborative story writing app.</small>
		</div>
	</div>
	<div class="overlay-protect"></div>
	<Account isAvailable/>
</header> -->
