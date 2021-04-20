<script>
	import Account from "./Account.svelte";
	import Timeline from "./Timeline.svelte";
	let isAvailable, wallet;
	isAvailable = (window.ethereum !== undefined);
</script>

<style>

</style>
<!--Structure-->
<div class="container-fluid mw-100">
	<div class="jumbotron bg-dark text-white text-center">
		<h1 class="display-4 app-title">StoryDAO</h1>
		<small class="lead">A decenteralized collaborative story writing app.</small>
	</div>
	<Account isAvailable/>

	<!-- <div class="navbar-fixed-bottom jumbotron">
		<div class="row">
			<div class="col">
				<p>Write</p>
			</div>
			<div class="col">
				<p>Proposal</p>
			</div>
			<div class="col">
				<p>Transact</p>
			</div>
		</div>
	</div> -->
</div>

<!-- <div class="card pt-0 pr-0 pl-0 pb-0">
	<div class="card-header text-white bg-dark">
		<h1 class="display-4">StoryDAO</h1>
		<small class="lead">A decenteralized collaborative story writing app.</small>
	</div>
	<div class="card-body">
		<div class="container-fluid">
			<div class="row">
				<Account isAvailable/>
			</div>
			<div class="row d-flex align-content-center">
				<Timeline/>
			</div>
		</div>
	</div>
</div> -->
