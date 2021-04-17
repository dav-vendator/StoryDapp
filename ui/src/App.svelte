<script>
	import Account from "./Account.svelte";
	import Timeline from "./Timeline.svelte";
	let isAvailable, wallet;
	isAvailable = (window.ethereum !== undefined);
</script>

<style>

</style>
<!--Structure-->
<div class="container-fluid">
	<div class="row jumbotron jumbotron-fluid">
		<div class="container-fluid">
			<h1 class="display-4">StoryDAO</h1>
			<p class="lead">A decenteralized collaborative story writing app.</p>
		</div>
	</div>
	<div class="row pt-2 float-left">
		 <Account isAvailable/>
	</div>
	<div class="row pt-2">
		<Timeline/>
	</div>
	<div class="row pt-1">
		<!--TimeLine-->
	</div>
</div>