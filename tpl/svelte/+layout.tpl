<script lang="ts">
  let { children } = $props()
</script>

<svelte:head>
  <title>标题占位</title>
</svelte:head>

{@render children()}
